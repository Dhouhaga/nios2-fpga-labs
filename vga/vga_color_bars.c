#include "system.h"
#include "io.h"
#include "unistd.h"

int main(void)
{
    alt_u32 bands[8] = {0xF00, 0x0F0, 0x00F, 0xFF0, 0xF0F, 0x0FF, 0xFFF, 0x000};
    int i;

    while (1) {
        for (i = 0; i < 8; i++)
            IOWR_32DIRECT(AVALON_VGA_0_BASE, i * 4, bands[i]);

        usleep(300000);

        /* Rotation des couleurs */
        alt_u32 tmp = bands[0];
        for (i = 0; i < 7; i++) bands[i] = bands[i + 1];
        bands[7] = tmp;
    }
    return 0;
}
