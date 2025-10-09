import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/rpp/rpp.dart';
import 'package:syathiby/utils/extension/typography.dart';

class DetailTeachingPlannerScreen extends HookConsumerWidget {
  final Rpp teachingPlanner;

  const DetailTeachingPlannerScreen({
    super.key,
    required this.teachingPlanner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail RPP'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10.0),
          // Nama Guru
          const Text(
            'Nama Guru',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.staff}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Tahun Ajaran
          const Text(
            'Tahun Ajaran',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.tahunAjaran}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Jenjang Pendidikan
          const Text(
            'Jenjang Pendidikan',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.jenjang}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Mata Pelajaran
          const Text(
            'Mata Pelajaran',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.mapel}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Kelas dan Semester
          const Text(
            'Kelas dan Semester',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.kelas} / ${teachingPlanner.semester}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Pertemuan ke-
          const Text(
            'Pertemuan ke',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.pertemuanKe}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Alokasi Waktu
          const Text(
            'Alokasi Waktu',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.alokasiWaktu}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Standar Kompetensi
          const Text(
            'Standar Kompetensi',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.standarKompetensi}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Kompetensi Dasar
          const Text(
            'Kompetensi Dasar',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.kompetensiDasar}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Indikator
          const Text(
            'Indikator',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.indikator}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Tujuan Pembelajaran
          const Text(
            'Tujuan Pembelajaran',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.tujuanPembelajaran}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Materi Ajar
          const Text(
            'Materi Ajar',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.materiAjar}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Metode Pembelajaran
          const Text(
            'Metode Pembelajaran',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.metodePembelajaran}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Langkah Pembelajaran
          const Text(
            'Langkah Pembelajaran',
          ),
          const SizedBox(height: 5.0),
          Text(
            htmlToPlainText('${teachingPlanner.langkahPembelajaran}'),
            style: context.titleMediumBold,
          ),
          // Alat dan Sumber
          const Text(
            'Alat dan Sumber',
          ),
          const SizedBox(height: 5.0),
          Text(
            '${teachingPlanner.alatSumberBelajar}',
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
          // Penilaian RPP
          const Text(
            'Penilaian RPP',
          ),
          const SizedBox(height: 5.0),
          Text(
            htmlToPlainText('${teachingPlanner.penilaian}'),
            style: context.titleMediumBold,
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  String htmlToPlainText(String htmlString) {
    final htmlDocument = HtmlParser.parseHTML(htmlString);
    return htmlDocument.text;
  }
}
