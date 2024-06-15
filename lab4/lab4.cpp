#include <iostream>

#define n 255
typedef unsigned char byte;

extern "C" void BigShowN(byte* p1, int p2);
extern "C" void Big3Sub(byte* M1, byte* M2, byte* M3, byte* Carry, short len);

int main() {
    byte x[n], y[n], z[n], carry;
    
    // Initialize arrays x, y, and z
    for (int i = 0; i < n; ++i) {
        x[i] = i;
        y[i] = i * 2;
        z[i] = 0;
    }

    // Display initial values of x, y, and z
    std::cout << "Initial values:\n";
    std::cout << "x: ";
    BigShowN(x, n);
    std::cout << "y: ";
    BigShowN(y, n);
    std::cout << "z: ";
    BigShowN(z, n);

    // Perform the operation z = x - y with carry
    Big3Sub(z, x, y, &carry, n);

    // Display the result and carry
    std::cout << "\nAfter subtraction:\n";
    std::cout << "Result (z): ";
    BigShowN(z, n);
    std::cout << "Carry: " << static_cast<int>(carry) << "\n";

    return 0;
}
