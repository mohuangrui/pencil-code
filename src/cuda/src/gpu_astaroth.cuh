extern "C" bool finalizeGpu(float *uu_x, float *uu_y, float *uu_z, float *lnrho);
extern "C" void RKintegration(float *uu_x, float *uu_y, float *uu_z, float *lnrho, int mx, int my, int mz, int nghost, int isubstep);
extern "C" void intitializeGPU(float *uu_x, float *uu_y, float *uu_z, float *lnrho, int nx, int ny, int nz, int nghost, float *x, float *y, float *z, float nu, float cs2);