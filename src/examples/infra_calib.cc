// #include <boost/filesystem.hpp>
// #include <boost/program_options.hpp>
// #include <boost/algorithm/string.hpp>
// #include <iomanip>
// #include <iostream>
// #include <Eigen/Eigen>
// #include <opencv2/highgui/highgui.hpp>
// #include <fstream>
// #include <thread>
// #include <limits>

// #ifdef HAVE_OPENCV3
// #include <opencv2/imgproc.hpp>
// #else
// #include <opencv2/imgproc/imgproc.hpp>
// #endif // HAVE_OPENCV3

// #ifdef HAVE_CUDA
// #ifdef HAVE_OPENCV3
// #include <opencv2/core/cuda.hpp>
// #else // HAVE_OPENCV3
// #include <opencv2/gpu/gpu.hpp>
// namespace cv {
//   namespace cuda = gpu;
// }
// #endif // HAVE_OPENCV3
// #endif // HAVE_CUDA

// #include "camodocal/infrastr_calib/InfrastructureCalibration.h"
#include <camodocal/sparse_graph/Pose.h>
#include <boost/make_shared.hpp>
// #include <Eigen/StdVector>

// std::vector<camodocal::CameraPtr> cameras;
// camodocal::InfrastructureCalibration INF(cameras);

using namespace std;

int main(){
    // printf("OK\n");
    // const std::string& path = "./";
    // INF.loadMap(path);
    // camodocal::InfrastructureCalibration::run();
    std::vector<boost::shared_ptr<camodocal::Pose> > test(10);
    for(int i = 0 ; i < 10; i++){
      // boost::shared_ptr<camodocal::Pose> p = boost::make_shared<camodocal::Pose>();
        // std::cout << i << std::endl;
        // boost::make_shared<Eigen::Vector4f>();
        test.push_back( boost::make_shared<camodocal::Pose>());
    }
    return 0;
}