#include<stdio.h>

#define ARRAY_SIZE 128*128
#define NUM_THREADS 128
#define BLOCK_SIZE 128

__global__ void reduce(float* d_out, float* d_in){

    int global_id = blockDim.x*blockIdx.x + threadIdx.x;
    int local_id = threadIdx.x;
    
    //extern __shared__ float s_in[];

    for(unsigned int s = blockDim.x/2; s > 0; s>>=1){
        if(local_id < s) d_in[global_id] += d_in[global_id + s];
        __syncthreads();
    }

    if(local_id==0) d_out[blockIdx.x] = d_in[global_id];
    __syncthreads();

}

int main(){

    float *d_in, *d_out, *d_final;
    const int ARRAY_BYTES = ARRAY_SIZE*sizeof(float);
    cudaMalloc((void**) &d_in, ARRAY_BYTES);
    cudaMalloc((void**) &d_out, ARRAY_BYTES/NUM_THREADS);
    cudaMalloc((void**) &d_final, sizeof(float));
    

    float h_array[ARRAY_SIZE];

    for(int i=0; i < ARRAY_SIZE; i+=1){
        h_array[i] = 1;
    }

    float sum;

    cudaMemcpy(d_in, h_array, ARRAY_BYTES, cudaMemcpyHostToDevice);

    reduce<<<BLOCK_SIZE, NUM_THREADS>>>(d_out, d_in);
    reduce<<<1, NUM_THREADS>>>(d_final, d_out);

    cudaMemcpy(&sum, d_out, sizeof(float), cudaMemcpyDeviceToHost);

    printf("%f",sum);

    cudaFree(d_in);
    cudaFree(d_out);
    cudaFree(d_final);


    return 0;
}