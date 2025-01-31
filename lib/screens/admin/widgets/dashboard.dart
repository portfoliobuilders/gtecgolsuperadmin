import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/models/admin_model.dart';
import 'package:gtecgolsuperadmin/provider/authprovider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboards extends StatefulWidget {
  const Dashboards({Key? key}) : super(key: key);

  @override
  State<Dashboards> createState() => _DashboardsState();
}

class _DashboardsState extends State<Dashboards> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAuthProvider>().AdminfetchCourseCountsProvider();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AdminAuthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading dashboard data...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.AdminfetchCourseCountsProvider(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = provider.courseCounts;
          if (data == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatCards(data),
                      const SizedBox(height: 24),
                      _buildDistributionItem(),
                      const SizedBox(height: 24),
                      _buildCoursesTable(context, data.detailedCounts),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Dashboard',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(CourseCountsResponse data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = (constraints.maxWidth - 48) / 4;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard('Total Students', data.studentCount.toString(),
                Icons.people, Colors.blue, cardWidth),
            _buildStatCard('Total Batches', data.batchCount.toString(),
                Icons.class_, Colors.blue, cardWidth),
            _buildStatCard('Total Courses', data.courseCount.toString(),
                Icons.school, Colors.blue, cardWidth),
            _buildStatCard('Total Teachers', data.teacherCount.toString(),
                Icons.person, Colors.blue, cardWidth),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color, // Set card color to the passed color
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20), // Text color set to white
                      overflow: TextOverflow.ellipsis)),
              Icon(icon,
                  color: Colors.white, size: 20), // Icon color set to white
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)), // Value text color set to white
        ],
      ),
    );
  }

  Widget _buildDistributionItem() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          )
        ],
      ),
      child: Consumer<AdminAuthProvider>(
        builder: (context, provider, child) {
          final courses = provider.courseCounts?.detailedCounts ?? [];
          if (courses.isEmpty) {
            return const Center(child: Text('No course data available'));
          }

          // Calculate the maximum student count for setting maxY
          double maxStudents = 0;
          for (var course in courses) {
            final totalStudents = course.batches.isNotEmpty
                ? course.batches
                    .map((batch) => batch.studentCount)
                    .reduce((a, b) => a + b)
                : 0;
            if (totalStudents > maxStudents) {
              maxStudents = totalStudents.toDouble();
            }
          }

          // Add 20% padding to the maxY value
          final maxY = (maxStudents * 1.2).ceilToDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Course Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: maxY / 5,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value >= 0 && value < courses.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: RotatedBox(
                                  quarterTurns: 0,
                                  child: Text(
                                    courses[value.toInt()].courseName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 60,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barGroups: List.generate(courses.length, (index) {
                      final course = courses[index];
                      final totalStudents = course.batches.isNotEmpty
                          ? course.batches
                              .map((batch) => batch.studentCount)
                              .reduce((a, b) => a + b)
                          : 0;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: totalStudents.toDouble(),
                            color: Colors.blue[300],
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                        left: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCoursesTable(
      BuildContext context, List<DetailedCourse> courses) {
    if (courses.isEmpty) {
      return const Center(child: Text('No courses available'));
    }

    return Container(
      width: double.infinity, // Ensure it takes the full width
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          )
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context)
              .size
              .width, // Ensures the table stretches to full width
        ),
        child: DataTable(
          headingRowHeight: 50,
          dataRowHeight: 60,
          horizontalMargin: 24,
          columnSpacing: 24,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headingRowColor: MaterialStateProperty.all(
            Colors.grey[50],
          ),
          columns: const [
            DataColumn(
                label: Text('Course',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Students',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Batches',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Action',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: courses.map((course) {
            final totalStudents = course.batches.isNotEmpty
                ? course.batches
                    .map((batch) => batch.studentCount)
                    .reduce((a, b) => a + b)
                : 0;

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        course.courseName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    totalStudents.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      course.batches.length.toString(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blue,
                        ),
                        onPressed: () {},
                        tooltip: 'Edit Course',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
