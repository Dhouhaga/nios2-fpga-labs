#include "io.h"
#include "system.h"
#include <stdint.h>

#define PWM_BASE       AVALON_PWM_0_BASE
#define PWM_REG_FREQ   0   /* mot 0 : freq (period_counts-1) */
#define PWM_REG_DUTY   1   /* mot 1 : duty (largeur active) */

int main(void) {
    /* Pour diviser l'horloge par 1024 cycles, il faut programmer freq = 1023 (0x03FF)
       car dans votre VHDL la période vaut freq+1 (compteur 0..freq inclus). */
    IOWR(PWM_BASE, PWM_REG_FREQ, 0x03FFu);

    /* 50% => duty = (freq+1)/2 = 1024/2 = 512 = 0x0200 */
    IOWR(PWM_BASE, PWM_REG_DUTY, 0x0200u);

    /* Boucle vide pour laisser tourner le PWM */
    while (1) { }
}
