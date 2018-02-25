#include <stdio.h>
#include "gputimer.h"

#define BLOCK_SIZE 1000
#define ARRAY_SIZE 100
#define NUM_THREADS 1000

__global__ void naive_add(int * g){

    int i = blockIdx.x*blockDim.x + threadIdx.x;

    i = i % ARRAY_SIZE;
    g[i] = g[i] + 1;

}

__global__ void atomic_add(int * g){

    int i = blockIdx.x*blockDim.x + threadIdx.x;

    i = i % ARRAY_SIZE;
    atomicAdd(& g[i], 1);

}

void print_array(int * h){
    for(int i=0; i < ARRAY_SIZE; i=i+1){
        printf("%d ", h[i]);
    }
    printf("\n");
}

int main(int argc, char **argv){
    
    GpuTimer timer;

    // Declaring and allocating host memory
    int h_array[ARRAY_SIZE];
    int ARRAY_BYTES = sizeof(int)*ARRAY_SIZE;

    // Declaring, allocating and assign zero to GPU memory
    int *d_array;
    cudaMalloc((void **) &d_array, ARRAY_BYTES);
    cudaMemset((void *) d_array, 0, ARRAY_BYTES);

    // first kernel
    timer.Start();
    naive_add<<<BLOCK_SIZE, NUM_THREADS>>>(d_array);
    timer.Stop();

    // back to host and print it
    cudaMemcpy(h_array, d_array, ARRAY_BYTES, cudaMemcpyDeviceToHost);
    print_array(h_array);
    cudaMemset((void *) d_array, 0, ARRAY_BYTES);    
    printf("Time elapsed using naive addition = %g ms\n", timer.Elapsed());

     // second kernel
     timer.Start();
     atomic_add<<<BLOCK_SIZE, NUM_THREADS>>>(d_array);
     timer.Stop();
 
     // back to host and print it
     cudaMemcpy(h_array, d_array, ARRAY_BYTES, cudaMemcpyDeviceToHost);
     print_array(h_array);
     printf("Time elapsed using atomic addition = %g ms\n", timer.Elapsed());

    cudaFree(d_array);
    return 0;

}