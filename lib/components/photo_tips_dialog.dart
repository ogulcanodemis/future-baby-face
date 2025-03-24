import 'package:flutter/material.dart';

class PhotoTipsDialog extends StatelessWidget {
  const PhotoTipsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ekran boyutunu alalım
    final screenSize = MediaQuery.of(context).size;
    final maxHeight = screenSize.height * 0.8; // Ekran yüksekliğinin %80'ini kullanalım
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      // Dialog boyutunu sınırlandıralım
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: screenSize.width * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tips for Great Results',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Do's Section
                const _SectionHeader(title: 'DO:', icon: Icons.check_circle, color: Colors.green),
                const SizedBox(height: 10),
                _buildTipItem(context, 
                  'Choose a clear, high-resolution photo',
                  'The clearer your face is in the photo, the better the AI can analyze features',
                  Icons.hd
                ),
                _buildTipItem(context, 
                  'Use photos with neutral lighting',
                  'Natural daylight gives the most accurate representation of your features',
                  Icons.wb_sunny
                ),
                _buildTipItem(context, 
                  'Select a front-facing portrait',
                  'Your face should be clearly visible and looking directly at the camera',
                  Icons.face
                ),
                _buildTipItem(context, 
                  'Use recent photos',
                  'Recent photos will provide the most accurate prediction of your baby',
                  Icons.new_releases
                ),
                
                const SizedBox(height: 15),
                
                // Don'ts Section
                const _SectionHeader(title: "DON'T:", icon: Icons.cancel, color: Colors.red),
                const SizedBox(height: 10),
                _buildTipItem(context, 
                  'Avoid photos with multiple people',
                  'The AI needs to focus on just your face, not others in the frame',
                  Icons.group_off
                ),
                _buildTipItem(context, 
                  'Avoid photos with filters or editing',
                  'Filters alter your actual features and affect the accuracy of predictions',
                  Icons.filter_alt_off
                ),
                _buildTipItem(context, 
                  'Avoid photos with sunglasses or hats',
                  'Your full face, including eyes and hair, should be visible',
                  Icons.no_photography
                ),
                _buildTipItem(context, 
                  'Avoid very dark or very bright photos',
                  'Poor lighting makes it difficult to analyze skin tone and features',
                  Icons.brightness_4
                ),
                
                const SizedBox(height: 20),
                
                // Example Pictures Section
                const Text(
                  'Example of Good Photos:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Image samples would go here in a real implementation
                    _buildExampleImage(context, Icons.check_circle, Colors.green, 'Good'),
                    _buildExampleImage(context, Icons.cancel, Colors.red, 'Bad'),
                  ],
                ),
                
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('I Understand', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExampleImage(BuildContext context, IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          width: 100, // Biraz küçültelim
          height: 100, // Biraz küçültelim
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 40, color: color),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
} 