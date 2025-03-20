import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class InjuryTypesScreen extends StatefulWidget {
  @override
  _InjuryTypesScreenState createState() => _InjuryTypesScreenState();
}

class _InjuryTypesScreenState extends State<InjuryTypesScreen> {
  DateTime? dateBlessure;
  String? selectedGravite;
  String? selectedStatut;

  final List<Map<String, dynamic>> injuryOptions = [
    {
      'name': 'Sprain',
      'icon': FontAwesomeIcons.undoAlt,  // Icône plus appropriée pour une entorse
      'description': 'A sprain is an injury to a ligament caused by overstretching.',
    },
    {
      'name': 'Fracture',
      'icon': FontAwesomeIcons.bone,  // Icône correcte pour une fracture
      'description': 'A fracture is a break in the bone caused by trauma or impact.',
    },
    {
      'name': 'Dislocation',
      'icon': FontAwesomeIcons.link,  // Icône plus appropriée pour une luxation
      'description': 'A dislocation occurs when two connected bones are forced apart.',
    },
    {
      'name': 'Strain',
      'icon': FontAwesomeIcons.personRunning,  // Icône plus appropriée pour une élongation
      'description': 'A strain is an injury to a muscle or tendon caused by overstretching.',
    },
    {
      'name': 'Contusion',
      'icon': FontAwesomeIcons.briefcaseMedical,  // Icône plus appropriée pour une contusion
      'description': 'A contusion is a bruise caused by a direct blow to the body.',
    },
  ];

  final List<String> graviteOptions = ['Low', 'Medium', 'High'];
  final List<String> statutOptions = ['Healing', 'Recovered', 'Injured'];

  // Method to build the injury card with the same design
  Widget _buildInjuryCard(Map<String, dynamic> injuryData) {
    final String injuryName = injuryData['name'];
    final IconData icon = injuryData['icon'];
    final String description = injuryData['description'];
    bool isSelected = selectedGravite == injuryName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedGravite = isSelected ? null : injuryName;
          });
        },
        child: Container(
          width: double.infinity,
          height: 130,
          decoration: ShapeDecoration(
            color: isSelected ? Color(0xFFF5BA41) : Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 2,
                color: const Color(0xFFF1F1F1),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            shadows: [
              BoxShadow(
                color: const Color(0x05323247),
                blurRadius: 15,
                offset: const Offset(0, 3),
                spreadRadius: -1.50,
              ),
              BoxShadow(
                color: const Color(0x0C0C1A4B),
                blurRadius: 3.75,
                offset: const Offset(0, 0),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        injuryName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF808B9A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          description,
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Color(0xFF808B9A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: isSelected
                      ? Icon(
                    icon,
                    size: 70,
                    color: Colors.white,
                  )
                      : CustomPaint(
                    size: Size(70, 70),
                    painter: GradientIconPainter(
                      icon: icon,
                      size: 70,
                      gradient: LinearGradient(
                        colors: [Color(0xFF4DD4DE), Color(0xFF0C1A37)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the dropdown field with the same design
  Widget _buildDropdownField(String label, List<String> options, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: options.contains(selectedValue) ? selectedValue : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: options.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
    );
  }

  // Date picker field with the same design
  Widget _buildDateField(String label, DateTime? selectedDate, Function(DateTime) onDateChanged) {
    return SizedBox(
      height: 60,
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) onDateChanged(pickedDate);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Color(0xFF39434F)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xFF0C1A37)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xFF4DD4DE)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(selectedDate != null ? selectedDate.toLocal().toString().split(' ')[0] : 'Select Date'),
        ),
      ),
    );
  }

  // Method to build the action button
  Widget _buildActionButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () {
          if (selectedGravite != null) {
            print('Gravité sélectionnée: $selectedGravite');
            Navigator.pushNamed(context, '/next_screen');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Veuillez sélectionner un type de blessure')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 70),
        ),
        child: const Text(
          'Confirmer',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            const SizedBox(height: 40),
            _buildTitleSection(),
            const SizedBox(height: 8),
            _buildSubtitle(),
            const SizedBox(height: 24),
            for (int i = 0; i < injuryOptions.length; i++) _buildInjuryCard(injuryOptions[i]),
            const SizedBox(height: 24),
            _buildDateField(
              'Date de la blessure',
              dateBlessure,
                  (pickedDate) {
                setState(() {
                  dateBlessure = pickedDate;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildDropdownField('Niveau de gravité', graviteOptions, selectedGravite, (newValue) {
              setState(() {
                selectedGravite = newValue;
              });
            }),
            const SizedBox(height: 24),
            _buildDropdownField('Statut de la récupération', statutOptions, selectedStatut, (newValue) {
              setState(() {
                selectedStatut = newValue;
              });
            }),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF808B9A), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Ajouter une blessure',
            style: TextStyle(
              color: const Color(0xFF808B9A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Text(
      'Détails de la blessure',
      style: TextStyle(
        color: const Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Complétez les informations suivantes:',
      style: TextStyle(
        color: const Color(0xFF808B9A),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
class GradientIconPainter extends CustomPainter {
  final IconData icon;
  final double size;
  final Gradient gradient;

  GradientIconPainter({
    required this.icon,
    required this.size,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, this.size, this.size);
    final Paint paint = Paint()..shader = gradient.createShader(rect);

    final TextSpan span = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: this.size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        foreground: paint,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}