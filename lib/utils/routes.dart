import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/views/home_page.dart';
import 'package:terra/views/home_page_children/home_page_main_children/applicant_page.dart';
import 'package:terra/views/home_page_children/home_page_main_children/employer_view/browse_employee_page.dart';
import 'package:terra/views/home_page_children/home_page_main_children/job_seeker_view/job_listing_page.dart';
import 'package:terra/views/home_page_children/home_page_main_children/job_seeker_view/job_offers.dart';
import 'package:terra/views/home_page_children/home_page_main_children/my_application.dart';
import 'package:terra/views/home_page_children/home_page_main_children/my_messages.dart';
import 'package:terra/views/home_page_children/home_page_main_children/my_task.dart';
import 'package:terra/views/home_page_children/home_page_main_children/task_history.dart';
import 'package:terra/views/home_page_children/home_page_main_children/transaction_history_page.dart';
import 'package:terra/views/home_page_children/profile_page_children/posted_jobs.dart';
import 'package:terra/views/home_page_children/profile_page_children/todo_tasks.dart';
import 'package:terra/views/landing_page.dart';
import 'package:terra/views/landing_page_children/auth/login_page.dart';
import 'package:terra/views/landing_page_children/auth/register_page.dart';

class RouteData {
  RouteData._pr();
  static final RouteData _instance = RouteData._pr();
  static RouteData get instance => _instance;
  static const Duration _transitionDuration = Duration(milliseconds: 500);
  Route<dynamic>? Function(RouteSettings) settings = (RouteSettings settings) {
    switch (settings.name) {
      case "/landing_page":
        return PageTransition(
          child: const LandingPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/browse_employees_page":
        final int? id = settings.arguments as int?;
        return PageTransition(
          child: BrowseEmployeePage(
            initialCategoryId: id,
          ),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/home_page":
        return PageTransition(
          child: const HomePage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/posted-jobs":
        return PageTransition(
          child: const PostedJobsPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/todo-tasks":
        return PageTransition(
          child: const TodoTasks(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/login_page":
        return PageTransition(
          child: const LoginPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/register_page":
        return PageTransition(
          child: const RegisterPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/my_task_page":
        return PageTransition(
          child: const MyTasks(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/job_offers_page":
        return PageTransition(
          child: const JobOffers(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/task_history_page":
        return PageTransition(
          child: const TaskHistory(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/transaction_history_page":
        return PageTransition(
          child: const TransactionHistoryPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/my_application_page":
        return PageTransition(
          child: const MyApplicationPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/applicant_page":
        return PageTransition(
          child: const ApplicantPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/my_messages":
        return PageTransition(
          child: const MyMessages(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/job_listing":
        final List args = settings.arguments as List;
        final int? catId = args[0];
        final String? keyword = args[1];
        return PageTransition(
          child: JobListingPage(
            catId: catId,
            keyword: keyword,
          ),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      default:
        return PageTransition(
          child: const LandingPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
    }
  };
}
