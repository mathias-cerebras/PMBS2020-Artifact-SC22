#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <float.h>
#include <math.h>
#include <time.h>

#include "../../constants.h"

#define N_RADIUS 4
#define N_THREADS_PER_BLOCK_DIM 8

__global__ void target_inner_3d_kernel(
    llint nx, llint ny, llint nz,
    llint x3, llint x4, llint y3, llint y4, llint z3, llint z4,
    llint lx, llint ly, llint lz,
    float hdx_2, float hdy_2, float hdz_2,
    float coef0,
    float coefx_1, float coefx_2, float coefx_3, float coefx_4,
    float coefy_1, float coefy_2, float coefy_3, float coefy_4,
    float coefz_1, float coefz_2, float coefz_3, float coefz_4,
    const float *__restrict__ u, float *__restrict__ v, const float *__restrict__ vp,
    const float *__restrict__ phi, const float *__restrict__ eta
) {
    const llint k = z3 + blockIdx.x * blockDim.x + threadIdx.x;
    const llint j = y3 + blockIdx.y * blockDim.y + threadIdx.y;
    const llint i = x3 + blockIdx.z * blockDim.z + threadIdx.z;

    if (i > x4-1 || j > y4-1 || k > z4-1) { return; }

    float lap = __fmaf_rn(coef0, u[IDX3_l(i,j,k)]
              , __fmaf_rn(coefx_1, __fadd_rn(u[IDX3_l(i+1,j,k)],u[IDX3_l(i-1,j,k)])
              , __fmaf_rn(coefy_1, __fadd_rn(u[IDX3_l(i,j+1,k)],u[IDX3_l(i,j-1,k)])
              , __fmaf_rn(coefz_1, __fadd_rn(u[IDX3_l(i,j,k+1)],u[IDX3_l(i,j,k-1)])
              , __fmaf_rn(coefx_2, __fadd_rn(u[IDX3_l(i+2,j,k)],u[IDX3_l(i-2,j,k)])
              , __fmaf_rn(coefy_2, __fadd_rn(u[IDX3_l(i,j+2,k)],u[IDX3_l(i,j-2,k)])
              , __fmaf_rn(coefz_2, __fadd_rn(u[IDX3_l(i,j,k+2)],u[IDX3_l(i,j,k-2)])
              , __fmaf_rn(coefx_3, __fadd_rn(u[IDX3_l(i+3,j,k)],u[IDX3_l(i-3,j,k)])
              , __fmaf_rn(coefy_3, __fadd_rn(u[IDX3_l(i,j+3,k)],u[IDX3_l(i,j-3,k)])
              , __fmaf_rn(coefz_3, __fadd_rn(u[IDX3_l(i,j,k+3)],u[IDX3_l(i,j,k-3)])
              , __fmaf_rn(coefx_4, __fadd_rn(u[IDX3_l(i+4,j,k)],u[IDX3_l(i-4,j,k)])
              , __fmaf_rn(coefy_4, __fadd_rn(u[IDX3_l(i,j+4,k)],u[IDX3_l(i,j-4,k)])
              , __fmul_rn(coefz_4, __fadd_rn(u[IDX3_l(i,j,k+4)],u[IDX3_l(i,j,k-4)])
    )))))))))))));

    v[IDX3_l(i,j,k)] = __fmaf_rn(2.f, u[IDX3_l(i,j,k)],
        __fmaf_rn(vp[IDX3(i,j,k)], lap, -v[IDX3_l(i,j,k)])
    );
}

__global__ void target_pml_3d_kernel(
    llint nx, llint ny, llint nz,
    llint x3, llint x4, llint y3, llint y4, llint z3, llint z4,
    llint lx, llint ly, llint lz,
    float hdx_2, float hdy_2, float hdz_2,
    float coef0,
    float coefx_1, float coefx_2, float coefx_3, float coefx_4,
    float coefy_1, float coefy_2, float coefy_3, float coefy_4,
    float coefz_1, float coefz_2, float coefz_3, float coefz_4,
    const float *__restrict__ u, float *__restrict__ v, const float *__restrict__ vp,
    float *__restrict__ phi, const float *__restrict__ eta
) {
    const llint k = blockIdx.x * blockDim.x + threadIdx.x;
    const llint j = blockIdx.y * blockDim.y + threadIdx.y;
    const llint i = blockIdx.z * blockDim.z + threadIdx.z;

    if (i >= x3 && i < x4 && j >= y3 && j < y4 && k >= z3 && k < z4) { return; }
    if (i > nx-1 || j > ny-1 || k > nz-1) { return; }

    float lap = __fmaf_rn(coef0, u[IDX3_l(i,j,k)]
              , __fmaf_rn(coefx_1, __fadd_rn(u[IDX3_l(i+1,j,k)],u[IDX3_l(i-1,j,k)])
              , __fmaf_rn(coefy_1, __fadd_rn(u[IDX3_l(i,j+1,k)],u[IDX3_l(i,j-1,k)])
              , __fmaf_rn(coefz_1, __fadd_rn(u[IDX3_l(i,j,k+1)],u[IDX3_l(i,j,k-1)])
              , __fmaf_rn(coefx_2, __fadd_rn(u[IDX3_l(i+2,j,k)],u[IDX3_l(i-2,j,k)])
              , __fmaf_rn(coefy_2, __fadd_rn(u[IDX3_l(i,j+2,k)],u[IDX3_l(i,j-2,k)])
              , __fmaf_rn(coefz_2, __fadd_rn(u[IDX3_l(i,j,k+2)],u[IDX3_l(i,j,k-2)])
              , __fmaf_rn(coefx_3, __fadd_rn(u[IDX3_l(i+3,j,k)],u[IDX3_l(i-3,j,k)])
              , __fmaf_rn(coefy_3, __fadd_rn(u[IDX3_l(i,j+3,k)],u[IDX3_l(i,j-3,k)])
              , __fmaf_rn(coefz_3, __fadd_rn(u[IDX3_l(i,j,k+3)],u[IDX3_l(i,j,k-3)])
              , __fmaf_rn(coefx_4, __fadd_rn(u[IDX3_l(i+4,j,k)],u[IDX3_l(i-4,j,k)])
              , __fmaf_rn(coefy_4, __fadd_rn(u[IDX3_l(i,j+4,k)],u[IDX3_l(i,j-4,k)])
              , __fmul_rn(coefz_4, __fadd_rn(u[IDX3_l(i,j,k+4)],u[IDX3_l(i,j,k-4)])
    )))))))))))));

    const float s_eta_c = eta[IDX3_eta1(i,j,k)];

    v[IDX3_l(i,j,k)] = __fdiv_rn(
        __fmaf_rn(
            __fmaf_rn(2.f, s_eta_c,
                __fsub_rn(2.f,
                    __fmul_rn(s_eta_c, s_eta_c)
                )
            ),
            u[IDX3_l(i,j,k)],
            __fmaf_rn(
                vp[IDX3(i,j,k)],
                __fadd_rn(lap, phi[IDX3(i,j,k)]),
                -v[IDX3_l(i,j,k)]
            )
        ),
        __fmaf_rn(2.f, s_eta_c, 1.f)
    );

    phi[IDX3(i,j,k)] = __fdiv_rn(
            __fsub_rn(
                phi[IDX3(i,j,k)],
                __fmaf_rn(
                __fmul_rn(
                    __fsub_rn(eta[IDX3_eta1(i+1,j,k)], eta[IDX3_eta1(i-1,j,k)]),
                    __fsub_rn(u[IDX3_l(i+1,j,k)], u[IDX3_l(i-1,j,k)])
                ), hdx_2,
                __fmaf_rn(
                __fmul_rn(
                    __fsub_rn(eta[IDX3_eta1(i,j+1,k)], eta[IDX3_eta1(i,j-1,k)]),
                    __fsub_rn(u[IDX3_l(i,j+1,k)], u[IDX3_l(i,j-1,k)])
                ), hdy_2,
                __fmul_rn(
                    __fmul_rn(
                        __fsub_rn(eta[IDX3_eta1(i,j,k+1)], eta[IDX3_eta1(i,j,k-1)]),
                        __fsub_rn(u[IDX3_l(i,j,k+1)], u[IDX3_l(i,j,k-1)])
                    ),
                hdz_2)
                ))
            )
        ,
        __fadd_rn(1.f, s_eta_c)
    );
}

__global__ void kernel_add_source_kernel(float *g_u, llint idx, float source) {
    g_u[idx] += source;
}

extern "C" void target(
    uint nsteps, double *time_kernel,
    llint nx, llint ny, llint nz,
    llint x1, llint x2, llint x3, llint x4, llint x5, llint x6,
    llint y1, llint y2, llint y3, llint y4, llint y5, llint y6,
    llint z1, llint z2, llint z3, llint z4, llint z5, llint z6,
    llint lx, llint ly, llint lz,
    llint sx, llint sy, llint sz,
    float hdx_2, float hdy_2, float hdz_2,
    const float *__restrict__ coefx, const float *__restrict__ coefy, const float *__restrict__ coefz,
    float *__restrict__ u, const float *__restrict__ v, const float *__restrict__ vp,
    const float *__restrict__ phi, const float *__restrict__ eta, const float *__restrict__ source
) {
    struct timespec start, end;

    const llint size_u = (nx + 2 * lx) * (ny + 2 * ly) * (nz + 2 * lz);
    const llint size_v = size_u;
    const llint size_phi = nx*ny*nz;
    const llint size_vp = size_phi;
    const llint size_eta = (nx+2)*(ny+2)*(nz+2);

    float *d_u, *d_v, *d_vp, *d_phi, *d_eta;
    cudaMalloc(&d_u, sizeof(float) * size_u);
    cudaMalloc(&d_v, sizeof(float) * size_v);
    cudaMalloc(&d_vp, sizeof(float) * size_vp);
    cudaMalloc(&d_phi, sizeof(float) * size_phi);
    cudaMalloc(&d_eta, sizeof(float) * size_eta);

    cudaMemcpy(d_u, u, sizeof(float) * size_u, cudaMemcpyHostToDevice);
    cudaMemcpy(d_v, v, sizeof(float) * size_v, cudaMemcpyHostToDevice);
    cudaMemcpy(d_vp, vp, sizeof(float) * size_vp, cudaMemcpyHostToDevice);
    cudaMemcpy(d_phi, phi, sizeof(float) * size_phi, cudaMemcpyHostToDevice);
    cudaMemcpy(d_eta, eta, sizeof(float) * size_eta, cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(N_THREADS_PER_BLOCK_DIM, N_THREADS_PER_BLOCK_DIM, N_THREADS_PER_BLOCK_DIM);

    int num_streams = 2;
    cudaStream_t streams[num_streams];
    for (int i = 0; i < num_streams; i++) {
        cudaStreamCreate(&(streams[i]));
    }

    const uint npo = 100;
    for (uint istep = 1; istep <= nsteps; ++istep) {
        clock_gettime(CLOCK_REALTIME, &start);

        dim3 n_block_inner(
            (z4-z3+N_THREADS_PER_BLOCK_DIM-1) / N_THREADS_PER_BLOCK_DIM,
            (y4-y3+N_THREADS_PER_BLOCK_DIM-1) / N_THREADS_PER_BLOCK_DIM,
            (x4-x3+N_THREADS_PER_BLOCK_DIM-1) / N_THREADS_PER_BLOCK_DIM);
        target_inner_3d_kernel<<<n_block_inner, threadsPerBlock, 0, streams[0]>>>(
            nx,ny,nz,
            x3,x4,y3,y4,z3,z4,
            lx,ly,lz,
            hdx_2, hdy_2, hdz_2,
            coefx[0]+coefy[0]+coefz[0],
            coefx[1], coefx[2], coefx[3], coefx[4],
            coefy[1], coefy[2], coefy[3], coefy[4],
            coefz[1], coefz[2], coefz[3], coefz[4],
            d_u, d_v, d_vp,
            d_phi, d_eta);

        dim3 n_block_pml(
            (nz+N_THREADS_PER_BLOCK_DIM-1) / N_THREADS_PER_BLOCK_DIM,
            (nx+N_THREADS_PER_BLOCK_DIM-1) / N_THREADS_PER_BLOCK_DIM,
            (ny+N_THREADS_PER_BLOCK_DIM-1) / N_THREADS_PER_BLOCK_DIM);
        target_pml_3d_kernel<<<n_block_pml, threadsPerBlock, 0, streams[1]>>>(
            nx,ny,nz,
            x3,x4,y3,y4,z3,z4,
            lx,ly,lz,
            hdx_2, hdy_2, hdz_2,
            coefx[0]+coefy[0]+coefz[0],
            coefx[1], coefx[2], coefx[3], coefx[4],
            coefy[1], coefy[2], coefy[3], coefy[4],
            coefz[1], coefz[2], coefz[3], coefz[4],
            d_u, d_v, d_vp,
            d_phi, d_eta);

        for (int i = 0; i < num_streams; i++) {
            cudaStreamSynchronize(streams[i]);
        }

        kernel_add_source_kernel<<<1, 1>>>(d_v, IDX3_l(sx,sy,sz), source[istep]);
        clock_gettime(CLOCK_REALTIME, &end);
        *time_kernel += (end.tv_sec  - start.tv_sec) +
                        (double)(end.tv_nsec - start.tv_nsec) / 1.0e9;

        float *t = d_u;
        d_u = d_v;
        d_v = t;

        // Print out
        if (istep % npo == 0) {
            printf("time step %u / %u\n", istep, nsteps);
        }
    }

    for (int i = 0; i < num_streams; i++) {
        cudaStreamDestroy(streams[i]);
    }


    cudaMemcpy(u, d_u, sizeof(float) * size_u, cudaMemcpyDeviceToHost);

    cudaFree(d_u);
    cudaFree(d_v);
    cudaFree(d_vp);
    cudaFree(d_phi);
    cudaFree(d_eta);
}

