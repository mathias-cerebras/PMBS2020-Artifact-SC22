#ifndef TARGET_3D_H
#define TARGET_3D_H

#include "../constants.h"
#include "../grid.h"

void target_3d(const struct grid_t grid, llint nx, llint ny, llint nz,
               llint x1, llint x2, llint x3, llint x4, llint x5, llint x6,
               llint y1, llint y2, llint y3, llint y4, llint y5, llint y6,
               llint z1, llint z2, llint z3, llint z4, llint z5, llint z6,
               llint lx, llint ly, llint lz,
               float hdx_2, float hdy_2, float hdz_2,
               const float *restrict coefx, const float *restrict coefy, const float *restrict coefz,
               const float *restrict u, float *restrict v, const float *restrict vp,
               float *restrict phi, const float *restrict eta);

#ifdef __NVCC__
void target(uint nsteps, double *time_kernel,
            llint nx, llint ny, llint nz,
            llint x1, llint x2, llint x3, llint x4, llint x5, llint x6,
            llint y1, llint y2, llint y3, llint y4, llint y5, llint y6,
            llint z1, llint z2, llint z3, llint z4, llint z5, llint z6,
            llint lx, llint ly, llint lz,
            llint sx, llint sy, llint sz,
            float hdx_2, float hdy_2, float hdz_2,
            const float *restrict coefx, const float *restrict coefy, const float *restrict coefz,
            float *restrict u, float *restrict v, const float *restrict vp,
            const float *restrict phi, const float *restrict eta, const float *restrict source);
#endif

#endif
