#include <stdio.h>
#include <stdint.h>

int main() {
    int8_t i8 = 63;
    int16_t i16 = 10110;
    int32_t i32 = 2000000000;
    int64_t i64 = 400000000;
   
    printf("int8_t(%llu): %i \n", sizeof(i8),i8);
    printf("int16_t(%llu): %i \n", sizeof(i16),i16);
    printf("int32_t(%llu): %i \n", sizeof(i32),i32);
    printf("int64_t(%llu): %lli \n", sizeof(i64),i64);
    
    uint8_t u8 = 255;
    uint16_t u16 = 65535;
    uint32_t u32 = 4294967295;
    uint64_t u64 = 1844674407370955165;

    printf("uint8_t(%llu): %u \n", sizeof(u8),u8);
    printf("uint16_t(%llu): %u \n", sizeof(u16),u16);
    printf("uint32_t(%llu): %u \n", sizeof(u32),u32);
    printf("uint64_t(%llu): %llu \n", sizeof(u64),u64);
    
    return 0;
}