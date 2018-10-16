#include <boost/filesystem.hpp>
#include <boost/program_options.hpp>
#include <boost/algorithm/string.hpp>
#include <iomanip>
#include <iostream>
#include <Eigen/Eigen>
#include <opencv2/highgui/highgui.hpp>
#include <fstream>
#include <thread>
#include <limits>

#ifdef HAVE_OPENCV3
#include <opencv2/imgproc.hpp>
#else
#include <opencv2/imgproc/imgproc.hpp>
#endif // HAVE_OPENCV3

#ifdef HAVE_CUDA
#ifdef HAVE_OPENCV3
#include <opencv2/core/cuda.hpp>
#else // HAVE_OPENCV3
#include <opencv2/gpu/gpu.hpp>
namespace cv {
  namespace cuda = gpu;
}
#endif // HAVE_OPENCV3
#endif // HAVE_CUDA

#include "camodocal/infrastr_calib/InfrastructureCalibration.h"

std::vector<camodocal::CameraPtr> cameras;
camodocal::InfrastructureCalibration INF(cameras);

int main(){
    printf("OK\n");
    const std::string& path = "map.sg";
    INF.loadMap(path);
    // camodocal::InfrastructureCalibration::run();
    return 0;
}