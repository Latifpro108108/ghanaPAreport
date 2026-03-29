import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../models/district.dart';

class DistrictSelectionScreen extends StatefulWidget {
  const DistrictSelectionScreen({super.key});

  @override
  State<DistrictSelectionScreen> createState() =>
      _DistrictSelectionScreenState();
}

class _DistrictSelectionScreenState extends State<DistrictSelectionScreen> {
  final List<District> _mockDistricts = [
    District(
      id: '1',
      name: 'Accra',
      region: 'Greater Accra',
      status: DistrictStatus.normal,
      activeReports: 0,
      isMonitored: false,
    ),
    District(
      id: '2',
      name: 'Kumasi',
      region: 'Ashanti',
      status: DistrictStatus.normal,
      activeReports: 0,
      isMonitored: false,
    ),
    District(
      id: '3',
      name: 'Takoradi',
      region: 'Western',
      status: DistrictStatus.normal,
      activeReports: 0,
      isMonitored: false,
    ),
    District(
      id: '4',
      name: 'Sekondi',
      region: 'Western',
      status: DistrictStatus.normal,
      activeReports: 0,
      isMonitored: false,
    ),
  ];

  late Set<String> _selectedDistricts;

  @override
  void initState() {
    super.initState();
    _selectedDistricts = {};
  }

  void _toggleDistrict(String districtId) {
    setState(() {
      if (_selectedDistricts.contains(districtId)) {
        _selectedDistricts.remove(districtId);
      } else {
        _selectedDistricts.add(districtId);
      }
    });
  }

  void _onContinue() {
    if (_selectedDistricts.isEmpty) {
      _showSnackBar('Please select at least one district');
      return;
    }

    context.go('/home');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Districts'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _mockDistricts.length,
              itemBuilder: (context, index) {
                final district = _mockDistricts[index];
                final isSelected = _selectedDistricts.contains(district.id);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  child: CheckboxListTile(
                    title: Text(district.name),
                    subtitle: Text(district.region),
                    value: isSelected,
                    onChanged: (value) {
                      _toggleDistrict(district.id);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ElevatedButton(
              onPressed: _onContinue,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
