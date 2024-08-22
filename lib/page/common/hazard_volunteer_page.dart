

import 'package:flutter/material.dart';
import 'package:forest_park_reports/page/common/hazard_modal_base.dart';
import 'package:forest_park_reports/page/hazard_report/image_submission.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class HazardVolunteerPage extends ConsumerStatefulWidget {
  
  const HazardVolunteerPage({super.key});

  @override
  ConsumerState<HazardVolunteerPage> createState() => _HazardVolunteerPageState();
}

class _HazardVolunteerPageState extends ConsumerState<HazardVolunteerPage> {

  XFile? hazardImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report New Hazard"),
      ),
      body: HazardModal(
        onSubmit: (context, ref, image, uuid, option) async {
          if (image == null) {
            if (!await showNoImageAlert(context)) {
              return false;
            } 
          }
          // TODO implement
          return true;
        },
      )
    );
  }
}