#include <SDL2/SDL.h>
#include <stdlib.h>
#include <string.h>
#include "../c_codegen.h"

typedef struct {
    SDL_Event raw;

    EventType type;

    int x, y;
    Key key;
    uint16_t modifiers;
    char* text;
    MouseButton mouseButton;
} SDLEvent;

SDLEvent* SEInit() {
    SDLEvent* out = malloc(sizeof(SDLEvent));

    out->type = EventType_None;
    out->text = malloc(32);

    return out;
}

void SEDestroy(SDLEvent* self) {
    free(self->text);
    free(self);
}

void SEGetPos(SDLEvent* self, int* x, int* y) {
    *x = self->x;
    *y = self->y;
}

Key SEGetKey(SDLEvent* self) {
    return self->key;
}

char* SEGetText(SDLEvent* self) {
    return self->text;
}

uint16_t SEGetModifiers(SDLEvent* self) {
    return self->modifiers;
}

BOOL HasMod(SDLEvent* self, SDL_Keymod mod) {
    return self->modifiers & mod > 0;
}

BOOL SEHasShift(SDLEvent* self) {
    return HasMod(self, KMOD_SHIFT);
}

BOOL SEHasControl(SDLEvent* self) {
    return HasMod(self, KMOD_CTRL);
}

BOOL SEHasAlt(SDLEvent* self) {
    return HasMod(self, KMOD_ALT);
}

BOOL SEHasCaps(SDLEvent* self) {
    return HasMod(self, KMOD_CAPS);
}

MouseButton SEGetMouseButton(SDLEvent* self) {
    return self->mouseButton;
}

EventType SEGetType(SDLEvent* self) {
    return self->type;
}

MouseButton TranslateMouseButton(SDLEvent* self) {
    switch (self->raw.button.button) {
        case SDL_BUTTON_LEFT:   return MouseButton_Left;
        case SDL_BUTTON_MIDDLE: return MouseButton_Middle;
        case SDL_BUTTON_RIGHT:  return MouseButton_Right;
        default:                return MouseButton_Unknown;
    }
}

Key TranslateKey(SDLEvent* self) {
    switch (self->raw.key.keysym.sym) {
        case SDLK_RETURN:    return Key_Return;
        case SDLK_ESCAPE:    return Key_Escape;
        case SDLK_BACKSPACE: return Key_Backspace;
        case SDLK_DELETE:    return Key_Delete;
        case SDLK_TAB:       return Key_Tab;

        case SDLK_INSERT:   return Key_Insert;
        case SDLK_HOME:     return Key_Home;
        case SDLK_END:      return Key_End;
        case SDLK_PAGEUP:   return Key_PageUp;
        case SDLK_PAGEDOWN: return Key_PageDown;

        case SDLK_RIGHT: return Key_ArrowRight;
        case SDLK_LEFT:  return Key_ArrowLeft;
        case SDLK_DOWN:  return Key_ArrowDown;
        case SDLK_UP:    return Key_ArrowUp;

        case SDLK_LCTRL:  return Key_LControl;
        case SDLK_RCTRL:  return Key_RControl;
        case SDLK_LSHIFT: return Key_LShift;
        case SDLK_RSHIFT: return Key_RShift;
        case SDLK_LALT:   return Key_LAlt;
        case SDLK_RALT:   return Key_RAlt;
        
        default: return Key_Unknown;
    }
}

int SEPoll(SDLEvent* self) {
    int out = SDL_PollEvent(&self->raw);

    switch (self->raw.type) {
        case SDL_QUIT: {
            self->type = EventType_Quit;
            break;
        }
        case SDL_KEYDOWN: {
            self->type = EventType_Key;
            self->key = TranslateKey(self);
            self->modifiers = self->raw.key.keysym.mod;
            break;
        }
        case SDL_TEXTINPUT: {
            self->type = EventType_Text;
            strcpy(self->text, self->raw.text.text);
            break;
        }
        case SDL_MOUSEMOTION: {
            self->type = EventType_MouseMove;
            self->x = self->raw.motion.x;
            self->y = self->raw.motion.y;
            break;
        }
        case SDL_MOUSEBUTTONDOWN: {
            self->type = EventType_MouseDown;
            self->x = self->raw.button.x;
            self->y = self->raw.button.y;
            self->mouseButton = TranslateMouseButton(self);
            break;
        }
        case SDL_MOUSEBUTTONUP: {
            self->type = EventType_MouseUp;
            self->x = self->raw.button.x;
            self->y = self->raw.button.y;
            self->mouseButton = TranslateMouseButton(self);
            break;
        }
        /*case SDL_MOUSEWHEEL: {
            self->type = EventType_MouseScroll;
            // todo: how do scroll selfs work?
            break;
        }*/
        default: {
            self->type = EventType_None;
            break;
        }
    }

    return out;
}