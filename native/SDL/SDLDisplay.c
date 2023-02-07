#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <stdio.h>
#include "../c_codegen.h"

#ifdef _WIN32
#include <windows.h>
#endif

typedef struct {
    SDL_Window* window;
    SDL_Renderer* renderer;

    SDLInitErrorCode errorCode;
} SDLDisplay;

SDLInitErrorCode SDGetErrorCode(SDLDisplay* self) {
    return self->errorCode;
}

SDLDisplay* LogSDLError(SDLDisplay* self, SDLInitErrorCode errorCode) {
    printf("SDL error: %s\n", SDL_GetError());
    if (self->window != NULL)
        SDL_DestroyWindow(self->window);

    if (self->renderer != NULL)
        SDL_DestroyRenderer(self->renderer);
    
    SDL_Quit();

    self->errorCode = errorCode;
    return self;
}

SDLDisplay* SDInit(const char* title, BOOL fullscreen) {
#ifdef _WIN32
    SetProcessDPIAware();
#endif

    SDLDisplay* out = malloc(sizeof(SDLDisplay));

    if (SDL_Init(SDL_INIT_VIDEO) != 0)
        return LogSDLError(out, SDLInitErrorCode_InitVideo_Fail);
    
    uint32_t flags = 0;
    if (fullscreen) flags |= SDL_WINDOW_FULLSCREEN_DESKTOP;
    else flags |= SDL_WINDOW_RESIZABLE;

    out->window = SDL_CreateWindow(title, 40, 40, 350, 350, flags);
    if (out->window == NULL)
        return LogSDLError(out, SDLInitErrorCode_CreateWindow_Fail);

    out->renderer = SDL_CreateRenderer(out->window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (out->renderer == NULL)
        return LogSDLError(out, SDLInitErrorCode_CreateRenderer_Fail);
    
    SDL_StartTextInput();

    out->errorCode = SDLInitErrorCode_Success;
    return out;
}

void SDDestroy(SDLDisplay* self) {
    SDL_DestroyRenderer(self->renderer);
    SDL_DestroyWindow(self->window);
    SDL_Quit();
    free(self);
}

void SDSetClip(SDLDisplay* self, int x, int y, int w, int h) {
    SDL_Rect clip = {
        x: x,
        y: y,
        w: w,
        h: h
    };
    SDL_RenderSetClipRect(self->renderer, &clip);
}

void SDResetClip(SDLDisplay* self) {
    SDL_RenderSetClipRect(self->renderer, NULL);
}

void SDSetColour(SDLDisplay* self, int r, int g, int b, int a) {
    SDL_SetRenderDrawColor(self->renderer, r, g, b, a);
}

void SDGetSize(SDLDisplay* self, int* w, int* h) {
/*
    SDL_DisplayMode dm;
    SDL_GetDesktopDisplayMode(0, &dm);
    *w = dm.w;
    *h = dm.h;
*/
    SDL_GetWindowSize(self->window, w, h);
}

void SDFlush(SDLDisplay* self) {
    SDL_RenderPresent(self->renderer);
    // SDSetColour(self, 0, 0, 0, 255);
    // SDL_RenderClear(self->renderer);
}

void SDDrawRect(SDLDisplay* self, int x, int y, int w, int h, int r, int g, int b, int a) {
    SDL_Rect rect = {x, y, w, h};
    SDSetColour(self, r, g, b, a);
    SDL_RenderDrawRect(self->renderer, &rect);
}

void SDFillRect(SDLDisplay* self, int x, int y, int w, int h, int r, int g, int b, int a) {
    SDL_Rect rect = {x, y, w, h};
    SDSetColour(self, r, g, b, a);
    SDL_RenderFillRect(self->renderer, &rect);
}

// NEEDS TO TAKE INTO ACCOUNT CLIP RECT!!
void SDClear(SDLDisplay* self, int r, int g, int b, int a) {
    // SDSetColour(self, r, g, b, a);
    // SDL_RenderClear(self->renderer);
    int w, h;
    SDGetSize(self, &w, &h);
    SDDrawRect(self, 0, 0, w, h, r, g, b, a);
}

SDL_Texture* GetTextTexture(SDLDisplay* self, TTF_Font* font, char* text, int r, int g, int b, int a, int* width, int* height) {
    SDL_Color col = {r, g, b, a};

    SDL_Surface* textSurface = TTF_RenderUTF8_Blended(font, text, col);
    SDL_Texture* textTexture = SDL_CreateTextureFromSurface(self->renderer, textSurface);
    *width = textSurface->w;
    *height = textSurface->h;
    SDL_FreeSurface(textSurface);
    return textTexture;
}

void RenderTexture(SDLDisplay* self, SDL_Texture* texture, int x, int y, int width, int height) {
    SDL_Rect renderRect = {x, y, width, height};
    SDL_RenderCopy(self->renderer, texture, NULL, &renderRect);
}

void SDDrawText(SDLDisplay* self, TTF_Font* font, char* text, int x, int y, int r, int g, int b, int a) {
    int width, height;
    SDL_Texture* textTexture = GetTextTexture(self, font, text, r, g, b, a, &width, &height);
    RenderTexture(self, textTexture, x, y, width, height);
    SDL_DestroyTexture(textTexture);
}