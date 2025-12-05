//#include <XSUtil/FunctionUtils/XSModelFunction.h>
//#include <XSUtil/FunctionUtils/XSModelFunctionUtils.h>
#include <XSFunctions/Utilities/XSModelFunction.h>
//#include <XSFunctions/Utilities/>
#include <XSstreams.h>

extern "C" void trapezoidmod(const RealArray& energy, const RealArray& params,
                             int spectrumNumber, RealArray& flux, RealArray& fluxError)
{
    Real E1 = params[0];
    Real E2 = params[1];
    Real E3 = params[2];
    Real E4 = params[3];
    Real amplitude = params[4];

    size_t Nflux = energy.size() - 1;
    flux.resize(Nflux);

    for (size_t i = 0; i < Nflux; ++i)
    {
        Real E_low = energy[i];
        Real E_high = energy[i + 1];

        if (E_high <= E1 || E_low >= E4)
        {
            flux[i] = 0.0;
        }
        else if (E_low >= E2 && E_high <= E3)
        {
            flux[i] = amplitude * (E_high - E_low);
        }
        else if (E_low < E2 && E_high > E1)
        {
            Real E_start = (E_low < E1) ? E1 : E_low;
            Real E_end = (E_high > E2) ? E2 : E_high;
            flux[i] = amplitude * (E_end - E_start) * ((E_end - E1) / (E2 - E1));
        }
        else if (E_low < E4 && E_high > E3)
        {
            Real E_start = (E_low < E3) ? E3 : E_low;
            Real E_end = (E_high > E4) ? E4 : E_high;
            flux[i] = amplitude * (E_end - E_start) * ((E4 - E_start) / (E4 - E3));
        }
        else
        {
            flux[i] = amplitude * (E_high - E_low);
        }
    }

    fluxError.resize(Nflux, 0.0); // エラーバーをゼロに設定
}
