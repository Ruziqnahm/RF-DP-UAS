import 'package:flutter/material.dart';

class StatusTimelineWidget extends StatelessWidget {
  final String currentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompact;

  const StatusTimelineWidget({
    Key? key,
    required this.currentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = _getStatusSteps();
    final currentIndex = _getCurrentStepIndex();

    if (isCompact) {
      return _buildCompactTimeline(steps, currentIndex);
    }

    return _buildFullTimeline(steps, currentIndex);
  }

  Widget _buildFullTimeline(List<Map<String, dynamic>> steps, int currentIndex) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isLast = index == steps.length - 1;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline indicator
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? step['color'] : Colors.grey[300],
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: step['color'].withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        step['icon'],
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 60,
                        color: isActive ? step['color'].withOpacity(0.5) : Colors.grey[300],
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Step content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: step['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Diperbarui: ${_formatDateTime(updatedAt)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: step['color'],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCompactTimeline(List<Map<String, dynamic>> steps, int currentIndex) {
    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? step['color'] : Colors.grey[300],
                        border: Border.all(
                          color: isCurrent ? step['color'] : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        step['icon'],
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['shortTitle'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? step['color'].withOpacity(0.5) : Colors.grey[300],
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _getStatusSteps() {
    if (currentStatus.toLowerCase() == 'cancelled') {
      return [
        {
          'title': 'Pesanan Dibuat',
          'shortTitle': 'Dibuat',
          'description': 'Pesanan telah diterima',
          'icon': Icons.check_circle,
          'color': Colors.blue,
        },
        {
          'title': 'Dibatalkan',
          'shortTitle': 'Batal',
          'description': 'Pesanan dibatalkan',
          'icon': Icons.cancel,
          'color': Colors.red,
        },
      ];
    }

    return [
      {
        'title': 'Menunggu Konfirmasi',
        'shortTitle': 'Pending',
        'description': 'Pesanan menunggu konfirmasi admin',
        'icon': Icons.hourglass_empty,
        'color': Colors.orange,
      },
      {
        'title': 'Sedang Diproses',
        'shortTitle': 'Proses',
        'description': 'Desain sedang disiapkan',
        'icon': Icons.sync,
        'color': Colors.blue,
      },
      {
        'title': 'Sedang Dicetak',
        'shortTitle': 'Cetak',
        'description': 'Pesanan sedang dalam proses printing',
        'icon': Icons.print,
        'color': Colors.purple,
      },
      {
        'title': 'Selesai',
        'shortTitle': 'Selesai',
        'description': 'Pesanan siap diambil',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
    ];
  }

  int _getCurrentStepIndex() {
    final status = currentStatus.toLowerCase();
    if (status == 'cancelled') return 1;
    if (status == 'pending') return 0;
    if (status == 'processing') return 1;
    if (status == 'printing') return 2;
    if (status == 'completed') return 3;
    return 0;
  }

  String _formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
