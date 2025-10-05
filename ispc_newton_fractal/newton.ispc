export void computeRoots(uniform int n,
                         uniform float rootsRe[], 
                         uniform float rootsIm[])
{
    /// @brief calculates roots of z^n - 1
    /// @param n - number of roots
    /// @param rootsRe - array to be filled with real parts of roots
    /// @param rootsIm - array to be filled with imaginary parts of roots

    foreach (k = 0 ... n) 
    {
        float angle = 2.0f * 3.14 * k / n;
        rootsRe[k] = cos(angle);
        rootsIm[k] = sin(angle);
    }
}

export void renderNewtonFractal(uniform int width,
                                uniform int height,
                                uniform int n,
                                uniform float rootsRe[],
                                uniform float rootsIm[],
                                uniform int maxIterations,
                                uniform float eps,
                                uniform unsigned int8 image[])
{
    /// @brief calculates color for Netwon fractal and inserts values to image
    /// @param width - number of pixels horizontally
    /// @param height - number of pixels vertically
    /// @param n - number of roots (for polynomial z^n - 1)
    /// @param rootsRe - array with values of real parts of roots
    /// @param rootsIm - array with values of imaginary parts of roots
    /// @param maxIterations - maximum number of iterations when calculating 
    /// @param eps - accuracy
    /// @param image - image buffor to fill with rgb values (value of i-th pixel is stored
    /// as RGB values in (image[i], image[i + 1], image[i + 2])

    foreach (i = 0 ... width*height) 
    {
        int y = i / width;
        int x = i % width;
        
        int idx = (y * width + x) * 3;

        // Map pixel to complex plane (-2..2 range)
        float re = 4.0f * ((float)x - (float)width * 0.5f) / (float)width;
        float im = 4.0f * ((float)y - (float)height * 0.5f) / (float)height;

        float zr = re;
        float zi = im;

        int iter = 0;
        int rootIndex = -1;

        for (; iter < maxIterations; ++iter) 
        {
            // Compute z^n (fr + i*fi)
            float fr = zr;
            float fi = zi;
            for (int j = 1; j < n; ++j) 
            {
                float tr = fr * zr - fi * zi;
                float ti = fr * zi + fi * zr;
                fr = tr; fi = ti;
            }

            // f(z) = z^n - 1
            fr -= 1.0f;

            // derivative df = n * z^(n-1)
            float dfr = 1.0f;
            float dfi = 0.0f;
            if (n > 1) 
            {
                dfr = zr; dfi = zi;
                for (int j = 2; j < n; ++j)
                {
                    float tr = dfr * zr - dfi * zi;
                    float ti = dfr * zi + dfi * zr;
                    dfr = tr; dfi = ti;
                }
            }
            dfr *= (float)n;
            dfi *= (float)n;

            float denom = dfr * dfr + dfi * dfi;
            if (denom < eps) break;

            // z = z - f/df
            float qr = (fr * dfr + fi * dfi) / denom;
            float qi = (fi * dfr - fr * dfi) / denom;
            zr -= qr;
            zi -= qi;

            // Check convergence to precomputed roots
            for (int k = 0; k < n; ++k) 
            {
                float dr = zr - rootsRe[k];
                float di = zi - rootsIm[k];
                if (dr * dr + di * di < eps * eps)
                {
                    rootIndex = k;
                    break;
                }
            }
            if (rootIndex != -1) break;
        }

        // Coloring
        unsigned int8 r, g, b;
        if (rootIndex == -1) 
        {
            r = g = b = 0; // black for non-converged
        } 
        else 
        {
            // Hue per root
            float hue = 360.0f * rootIndex / (float)n;

            // Brightness
            float brightness = 0.5f + 0.5f * (1.0f - (float)iter / (float)maxIterations);
            float sat = 1.0f;

            float c = brightness * sat;
            float xh = c * (1.0f - abs(fmod(hue / 60.0f, 2.0f) - 1.0f));
            float m = brightness - c;

            float rf = 0.0f, gf = 0.0f, bf = 0.0f;
            if      (hue < 60.0f)  { rf = c;  gf = xh; bf = 0.0f; }
            else if (hue < 120.0f) { rf = xh; gf = c;  bf = 0.0f; }
            else if (hue < 180.0f) { rf = 0.0f; gf = c;  bf = xh; }
            else if (hue < 240.0f) { rf = 0.0f; gf = xh; bf = c;  }
            else if (hue < 300.0f) { rf = xh; gf = 0.0f; bf = c;  }
            else                   { rf = c;  gf = 0.0f; bf = xh; }

            // Convert to 0..255 and cast
            r = (unsigned int8)clamp((rf + m) * 255.0f, 0.0f, 255.0f);
            g = (unsigned int8)clamp((gf + m) * 255.0f, 0.0f, 255.0f);
            b = (unsigned int8)clamp((bf + m) * 255.0f, 0.0f, 255.0f);
        }

        // Store the pixel
        image[idx] = r;
        image[idx + 1] = g;
        image[idx + 2] = b;
    }
}
