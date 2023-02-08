#include <stdlib.h>
#include <stdint.h>

void* UniverseInit() {
    return malloc(512);
}

void UniverseDestroy(uint8_t* self) {
    free(self);
}

void UniverseSet(uint8_t* self, uint16_t index, uint8_t level) {
    self[index - 1] = level;
}

uint8_t UniverseGet(uint8_t* self, uint16_t index) {
    return self[index - 1];
}