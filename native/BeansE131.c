#include "thirdparty/libe131/e131.c"

// libe131 with Beans compatibility layer

#include "c_codegen.h"
#include <stdlib.h>

typedef struct {
  int sockfd;
  e131_packet_t packet;
  e131_addr_t dest;
  BeansE131ErrorCode err;
} BeansE131;

BeansE131ErrorCode BeansE131GetError(BeansE131* self) {
  return self->err;
}

BeansE131* BeansE131Init(char* source_name, char* dest, uint16_t universe) {
  BeansE131* out = malloc(sizeof(BeansE131));
  if ((out->sockfd = e131_socket()) < 0) {
    out->err = BeansE131ErrorCode_socket;
    return out;
  }
  
  e131_pkt_init(&out->packet, universe, 512);

  if (strlen(source_name) > 63) {
    out->err = BeansE131ErrorCode_source_name;
    return out;
  }
  memcpy(&out->packet.frame.source_name, source_name, strlen(source_name) + 1);

  if (e131_unicast_dest(&out->dest, dest, E131_DEFAULT_PORT) < 0) {
    out->err = BeansE131ErrorCode_unicast_dest;
    return out;
  }

  out->err = BeansE131ErrorCode_success;
  return out;
}

// todo: close sockfd?
void BeansE131Destroy(BeansE131* self) {
    free(self);
}

void BeansE131Print(BeansE131* self) {
  e131_pkt_dump(stdout, &self->packet);
}

uint8_t* BeansE131GetUniverseStart(BeansE131* self) {
    return &self->packet.dmp.prop_val[1];
}

BOOL BeansE131Send(BeansE131* self) {
  int ret = e131_send(self->sockfd, &self->packet, &self->dest);
  self->packet.frame.seq_number++;
  if (ret < 0) return FALSE;
  return TRUE;
}