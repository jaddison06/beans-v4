#include <SDL2/SDL_ttf.h>
#include "../c_codegen.h"

BOOL SFInit() {
    return TTF_Init() == 0;
}

void SFQuit() {
    TTF_Quit();
}

TTF_Font* SFCreate(char* family, int size) {
    return TTF_OpenFont(family, size);
}

void SFDestroy(TTF_Font* self) {
    TTF_CloseFont(self);
}

void SFGetTextSize(TTF_Font* self, char* text, int* width, int* height) {
    TTF_SizeText(self, text, width, height);
}