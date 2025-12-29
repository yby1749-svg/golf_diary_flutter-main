// lib/data/default_courses.dart
import '../models/golf_course.dart';

final List<GolfCourse> kDefaultCourses = [
  GolfCourse(
    clubName: 'Korea Country Club',
    courseName: 'Main Course',
    pars: [4,4,3,4,5,4,3,4,4,  4,4,4,5,3,4,4,3,5],
    country: 'KR',
  ),
  GolfCourse(
    clubName: 'Tokyo Golf Club',
    courseName: 'East Course',
    pars: [4,4,4,5,3,4,4,3,5,  4,4,3,4,5,4,3,4,4],
    country: 'JP',
  ),
  GolfCourse(
    clubName: 'Manila Golf & Country Club',
    courseName: 'Championship',
    pars: [4,4,3,4,5,4,3,4,4,  4,4,4,5,3,4,4,3,5],
    country: 'PH',
  ),
  GolfCourse(
    clubName: 'Mission Hills Golf Club',
    courseName: 'World Cup Course',
    pars: [4,4,4,5,3,4,4,3,5,  4,4,3,4,5,4,3,4,4],
    country: 'CN',
  ),
];
