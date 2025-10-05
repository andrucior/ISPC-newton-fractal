#include <iostream>
#include <vector>
#include <cmath>
#include <string>
#include <chrono>
#include <cstdint>
#include "newton_ispc.h"   
#include "fileUtils.h"    

using namespace ispc;

int main() {
    int n;
    std::string input;

    const int width = 800;
    const int height = 800;
    const int maxIterations = 50;
    const double eps_d = 1e-6;
    const double PI = 3.141592653589793;

    while (true) {
        std::cout << "Provide the n for Newton's fractal:\n";
        std::getline(std::cin, input);

        try {
            size_t pos;
            n = std::stoi(input, &pos);
            if (pos != input.size() || n <= 0) throw std::invalid_argument("invalid");

            // Image buffer
            std::vector<uint8_t> image(width * height * 3);

            // Precompute roots
            std::vector<float> rootsRe(n), rootsIm(n);
            for (int k = 0; k < n; ++k) {
                double angle = 2.0 * PI * k / n;
                rootsRe[k] = static_cast<float>(std::cos(angle));
                rootsIm[k] = static_cast<float>(std::sin(angle));
            }

            auto start = std::chrono::high_resolution_clock::now();

            // Call ISPC function
            renderNewtonFractal(width,
                height,
                n,
                rootsRe.data(),
                rootsIm.data(),
                maxIterations,
                eps_d,
                image.data());

            auto end = std::chrono::high_resolution_clock::now();
            auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
            std::cout << "Calculations finished in " << ms.count() << " ms\n";

            // Save as PNG 
            FileHandler::writePNG(image.data(), width, height, "newton.png");

            return 0;
        }
        catch (...) {
            std::cerr << "Invalid input, please provide a natural number\n";
        }
    }
}