#include<stdio.h>

#define NUM_THREADS 100
#define BLOCK_SIZE 100 

__global__ void blur(int * g, int * img, int * filter){
    int i = threadIdx.x;
    
}

int main(int argv, char* argc){
    
    int img[100][100];
    int filter[4][4] = {1, 1, 1, 1, 1, 3, 3, 1, 1, 3, 3, 1, 1, 1, 1, 1};

    const int ARRAY_BYTES = sizeof(int)*100*100;
    
    // creating half black half white image

    for(int i=0; i<100; i=i+1){
        for(int j=0; j<50; j=j+1){
            img[i][j] = 0;
        }
    }

    for(int i=0; i<100; i=i+1){
        for(int j=50; j<100; j=j+1){
            img[i][j] = 255;
        }
    }

    // declaring and allocating GPU memory

    int* d_array;
    cudaMalloc((void **) &d_array, ARRAY_BYTES);
    cudaMemset((void *) d_array, 0, ARRAY_BYTES);

    int* d_img;
    cudaMalloc((void **) &d_img, ARRAY_BYTES);
    cudaMemcpy(d_img, img, ARRAY_BYTES, cudaMemcpyHostToDevice);

    blur<<<BLOCK_SIZE, NUM_THREADS>>>(d_array, d_img, filter);






    return 0;
}