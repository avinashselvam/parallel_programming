#include<stdio.h>

__global__ void shift(int * g){

    int i = threadIdx.x;

    __shared__ int array[128];

    array[i] = i;
    __syncthreads();

    if(i<127){
        int temp = array[i + 1];
        __syncthreads();
        
        array[i] = temp;
        __syncthreads();
    }

    g[i] = array[i];
    __syncthreads(); // not really necessary as no further operations
}

// helper function

void print_array(int * h){
    for(int i=0; i < 128; i=i+1){
        printf("%d ", h[i]);
    }
    printf("\n");
}

int main(){

    // array on host memory
    int h_array[128];
    const int ARRAY_BYTES = sizeof(int)*128;

    // array on Device global memory
    int * d_array;
    cudaMalloc((void **) &d_array, ARRAY_BYTES);

    // kernel call
    shift<<<1,128>>>(d_array);

    // get results from Device global to host
    cudaMemcpy(h_array, d_array, ARRAY_BYTES, cudaMemcpyDeviceToHost);

    // see results
    print_array(h_array);

    cudaFree(d_array);
    
    return 0;
}