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
// 
#include "camodocal/infrastr_calib/InfrastructureCalibration.h"
#include <boost/make_shared.hpp>
#include <camodocal/sparse_graph/SparseGraph.h>

std::vector<camodocal::CameraPtr> cameras;
camodocal::InfrastructureCalibration INF(cameras);

using namespace std;
using namespace camodocal;

int main(){
    const std::string& path = "./";
    INF.loadMap(path);
    // boost::shared_ptr<Pose> a = boost::make_shared<Pose>();
    // camodocal::InfrastructureCalibration::run();
    // std::vector<camodocal::PosePtr> test(10);
    // camodocal::Pose a;
    // for(int i = 0 ; i < 10; i++){
    //     ok
    //     test.at(i) = boost::allocate_shared<camodocal::Pose>(Eigen::aligned_allocator<camodocal::Pose>());
    //     gg
    //     test.push_back( boost::make_shared<camodocal::Pose>());
    // }
    return 0;
}