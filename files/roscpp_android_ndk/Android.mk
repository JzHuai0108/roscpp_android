LOCAL_PATH := $(call my-dir)

# Note the order of these libs matters in linking. Generally speaking, if lib b depends on lib a, then write lib b earlier than lib a.
# If in jni ndk-build, the undefined reference errors arise, make sure that the order of libraries follow the above rule.
stlibs := xmlrpcpp Bullet3Geometry  boost_stacktrace_basic  diagnostic_aggregator  pcl_recognition  orocos-bfl  yaml-cpp  \
 boost_math_tr1  charset  amcl_sensors  base_local_planner  theoraenc  vorbisfile  orocos-kdl  opencv_imgcodecs3  opencv_xobjdetect3  \
 opencv_videoio3  SDLmain  boost_signals  image_publisher  SDL_image  image_proc  opencv_reg3  xml2  camera_calibration_parsers  \
 move_base  boost_container  joint_state_listener  boost_context  bondcpp  boost_math_c99f  camera_info_manager  opencv_calib3d3  \
 boost_math_c99l  navfn  tinyxml2  pcl_io_ply  boost_iostreams  opencv_xfeatures2d3  opencv_stereo3  urdfdom_world  boost_thread  \
 eigen_conversions  boost_program_options  roslib  boost_coroutine  pcl_common  opencv_xphoto3  PocoNet  boost_timer  Bullet3Dynamics  \
 opencv_ml3  boost_contract  ogg  opencv_plot3  collada-dom2.4-dp  tf tf2 rosbag_storage bz2 opencv_rgbd3  boost_type_erasure  interactive_markers  \
 boost_log_setup  tinyxml  boost_atomic  flann_cpp_s-gd  pcl_search  laser_geometry  boost_random  pcl_ros_surface   boost_date_time  \
 opencv_structured_light3  urdf  theora  opencv_optflow3  params  qhullcpp  uuid  pcl_surface  map_server2  map_server_image_loader \
 rosconsole_backend_interface  urdfdom_model  LinearMath  tf2_ros  Bullet3OpenCL_clew  vorbisenc  pcl_features  pluginlib_tutorials  \
 tf_conversions  opencv_fuzzy3  pcl_registration  opencv_saliency3  boost_test_exec_monitor  theoradec  boost_stacktrace_noop  \
 opencv_img_hash3  opencv_ccalib3  boost_system  PocoUtild  opencv_tracking3  opencv_superres3  opencv_core3  roslz4  lz4  opencv_surface_matching3  \
 pointcloud_filters  roscpp_serialization  opencv_phase_unwrapping3  compressed_image_transport  compressed_depth_image_transport  \
 move_slow_and_clear  PocoXML  assimp  pcl_kdtree  PocoJSON  opencv_aruco3  cpp_common console_bridge rosconsole_bridge pcl_ros_filters  \
 opencv_ximgproc3  pcl_io  opencv_bgsegm3  boost_exception  pcl_sample_consensus  layers  Bullet3Collision  BulletCollision  \
 robot_state_publisher_solver  opencv_imgproc3  depth_image_proc  rosbag  pcl_filters  stereo_image_proc  octomap  pcl_segmentation  \
 opencv_video3  pcl_stereo  rosconsole_android  boost_math_c99  kdl_conversions  boost_prg_exec_monitor  opencv_dnn3  opencv_line_descriptor3  \
 image_transport_plugins  amcl_node amcl_map  opencv_objdetect3  pcl_octree  polled_camera  boost_math_tr1l  boost_math_tr1f  voxel_grid  \
 flann_cpp_s  qhullstatic_r  actionlib  boost_wave  PocoUtil  opencv_bioinspired3  image_geometry  theora_image_transport  opencv_text3  \
 kdl_parser  urdfdom_sensor  Bullet3Common  pcl_ros_tf  opencv_highgui3  costmap_2d  opencv_dpm3  Bullet2FileLoader  carrot_planner  \
 nodeletlib  BulletSoftBody  pcl_keypoints  pcl_ros_segmentation  curl  opencv_features2d3  increment  mean  PocoXMLd  boost_log  cv_bridge  \
 roscpp  rotate_recovery  opencv_photo3  SDL  pcl_ros_features  clear_costmap_recovery  opencv_datasets3  rospack  random_numbers  \
 boost_graph  BulletDynamics  iconv  image_rotate  dynamic_reconfigure_config_init_mutex  image_transport  opencv_shape3  octomath  amcl_pf  \
 opencv_flann3  nodelet_math  PocoJSONd  pcl_ros_io  median  rostime  boost_regex  trajectory_planner_ros  message_filters  opencv_videostab3  \
 pcl_ml  PocoFoundationd  global_planner  resource_retriever  boost_wserialization  rosconsole  pluginlib  boost_unit_test_framework  \
 opencv_face3  octomap_ros  PocoFoundation  transfer_function  qhullstatic  laser_scan_filters  opencv_stitching3  class_loader  vorbis  \
 urdfdom_model_state  boost_filesystem  geometric_shapes  boost_chrono  boost_serialization  PocoNetd  dwa_local_planner  topic_tools  \
 laser_scan_matcher polar_scan_matcher csm-static

define include_shlib
$(eval include $$(CLEAR_VARS))
$(eval LOCAL_MODULE := $(1))
$(eval LOCAL_SRC_FILES := $$(LOCAL_PATH)/../lib/lib$(1).so)
$(eval include $$(PREBUILT_SHARED_LIBRARY))
endef
define include_stlib
$(eval include $$(CLEAR_VARS))
$(eval LOCAL_MODULE := $(1))
$(eval LOCAL_SRC_FILES := ../lib/lib$(1).a)
$(eval include $$(PREBUILT_STATIC_LIBRARY))
endef

$(foreach stlib,$(stlibs),$(eval $(call include_stlib,$(stlib))))

include $(CLEAR_VARS)
LOCAL_MODULE    := roscpp_android_ndk
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include
LOCAL_EXPORT_CPPFLAGS := -fexceptions -frtti
LOCAL_CPP_FEATURES := exceptions
LOCAL_EXPORT_LDLIBS := $(foreach l,$(stlibs),-l$(l)) -L$(LOCAL_PATH)/../lib
LOCAL_EXPORT_LDLIBS += -L$(LOCAL_PATH)/../share/OpenCV-3.3.1-dev/3rdparty/lib -ltegra_hal
LOCAL_STATIC_LIBRARIES := $(stlibs) c++_static

include $(BUILD_STATIC_LIBRARY)
