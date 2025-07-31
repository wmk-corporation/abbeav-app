import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../style/app_color.dart';

enum PaymentMethod { card, mobileMoney }

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  int? selectedTicketIndex;
  PaymentMethod? selectedPaymentMethod;

  final List<Map<String, dynamic>> ticketCategories = [
    {
      'name': 'Canal Olympia',
      'backImage':
          'https://cdn.tripinafrica.com/places/canal-olympia-1740433127.jpg',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQgqncKaUAFayALhexeEllosqhVZL88PhAHkg&s',
      'desc':
          'Vivez l’expérience cinéma Canal Olympia. Salle moderne, son immersif, films récents.',
      'places': 120,
      'price': 3500,
    },
    {
      'name': 'Cinema Eden',
      'backImage':
          'https://www.europeanfilmacademy.org/app/uploads/2022/10/eden-cinemas-opening-33.jpg',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHcbSZPexi-bXsb9tb0cdNmfR3xVD-qQ4nYw&s',
      'desc':
          'Découvrez le charme du cinéma Eden. Ambiance conviviale, films pour tous.',
      'places': 80,
      'price': 3500,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          children: [
            // --- Pub Carousel ---
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 10),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 170,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
                items: ticketCategories.map((cat) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            cat['backImage'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black.withOpacity(0.18),
                            colorBlendMode: BlendMode.darken,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(18)),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.01),
                                  Colors.black.withOpacity(0.7)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    shadows: [
                                      Shadow(blurRadius: 8, color: Colors.black)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat['desc'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.92),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            // --- Tickets à acheter ---
            ...List.generate(ticketCategories.length, (i) {
              final cat = ticketCategories[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTicketIndex = i;
                    selectedPaymentMethod = null; // reset payment method
                  });
                },
                child: _CardTicket(
                  image: cat['image'],
                  name: cat['name'],
                  desc: cat['desc'],
                  places: cat['places'],
                  price: cat['price'],
                  isSelected: selectedTicketIndex == i,
                ),
              );
            }),
            const SizedBox(height: 24),
            if (selectedTicketIndex != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  "Choisissez votre moyen de paiement",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  children: [
                    _PaymentOptionCard(
                      icon: Icons.credit_card,
                      label: "Carte Bancaire",
                      selected: selectedPaymentMethod == PaymentMethod.card,
                      onTap: () {
                        setState(() {
                          selectedPaymentMethod = PaymentMethod.card;
                        });
                        _showPaymentBottomSheet(context, PaymentMethod.card);
                      },
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    const SizedBox(width: 18),
                    _PaymentOptionCard(
                      icon: Icons.phone_android,
                      label: "Mobile Money",
                      selected:
                          selectedPaymentMethod == PaymentMethod.mobileMoney,
                      onTap: () {
                        setState(() {
                          selectedPaymentMethod = PaymentMethod.mobileMoney;
                        });
                        _showPaymentBottomSheet(
                            context, PaymentMethod.mobileMoney);
                      },
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7D3CF8), Color(0xFF3DCBFF)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  void _showPaymentBottomSheet(BuildContext context, PaymentMethod method) {
    final ticket = ticketCategories[selectedTicketIndex!];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Paiement - ${ticket['name']}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 18),
              if (method == PaymentMethod.card)
                _CardPaymentForm(ticket: ticket)
              else
                _MobileMoneyPaymentForm(ticket: ticket),
            ],
          ),
        );
      },
    );
  }
}

class _CardTicket extends StatefulWidget {
  final String image;
  final String name;
  final String desc;
  final int places;
  final int price;
  final bool isSelected;

  const _CardTicket({
    required this.image,
    required this.name,
    required this.desc,
    required this.places,
    required this.price,
    this.isSelected = false,
  });

  @override
  State<_CardTicket> createState() => _CardTicketState();
}

class _CardTicketState extends State<_CardTicket>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.isSelected
        ? AnimatedBuilder(
            animation: _gradientAnim,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    width: 3,
                    style: BorderStyle.solid,
                    color: Colors.transparent,
                  ),
                  gradient: LinearGradient(
                    colors: const [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      _gradientAnim.value * 0.5,
                      1 - _gradientAnim.value * 0.5
                    ],
                    transform: GradientRotation(_gradientAnim.value * 3.14),
                  ),
                ),
                child: _buildCardContent(),
              );
            },
          )
        : _buildCardContent();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: widget.isSelected
          ? border
          : Container(
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildCardContent(),
            ),
    );
  }

  Widget _buildCardContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image catégorie
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(18)),
            child: Image.network(
              widget.image,
              width: 90,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.desc,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event_seat, color: Colors.white70, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.places} places disponibles",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Prix + bouton animé
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${widget.price} FCFA",
                style: const TextStyle(
                    color: Color(0xFF3DCBFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                  ),
                  onPressed: () {
                    // L'achat se fait via le choix de paiement, donc rien ici
                  },
                  child: const Text(
                    "Acheter",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Gradient gradient;

  const _PaymentOptionCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: selected ? gradient : null,
            color: selected ? null : AppColor.primary,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF3DCBFF).withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
            border: selected
                ? Border.all(color: Colors.transparent, width: 0)
                : Border.all(color: Colors.white12, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPaymentForm extends StatefulWidget {
  final Map<String, dynamic> ticket;
  const _CardPaymentForm({required this.ticket});

  @override
  State<_CardPaymentForm> createState() => _CardPaymentFormState();
}

class _CardPaymentFormState extends State<_CardPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiry = '';
  String cvv = '';
  String name = '';
  bool isLoading = false;

  void _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Paiement par carte effectué avec succès !"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Numéro de carte",
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 19,
            validator: (v) =>
                v != null && v.length >= 16 ? null : "Numéro invalide",
            onChanged: (v) => cardNumber = v,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Expiration",
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                  maxLength: 5,
                  validator: (v) => v != null && v.length == 5 ? null : "MM/YY",
                  onChanged: (v) => expiry = v,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "CVV",
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (v) => v != null && v.length >= 3 ? null : "CVV",
                  onChanged: (v) => cvv = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Nom sur la carte",
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(),
            ),
            validator: (v) => v != null && v.isNotEmpty ? null : "Nom requis",
            onChanged: (v) => name = v,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3DCBFF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Payer ${widget.ticket['price']} FCFA",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileMoneyPaymentForm extends StatefulWidget {
  final Map<String, dynamic> ticket;
  const _MobileMoneyPaymentForm({required this.ticket});

  @override
  State<_MobileMoneyPaymentForm> createState() =>
      _MobileMoneyPaymentFormState();
}

class _MobileMoneyPaymentFormState extends State<_MobileMoneyPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  String phone = '';
  String operator = '';
  bool isLoading = false;

  void _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Paiement Mobile Money effectué avec succès !"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "Opérateur",
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                  value: "Orange Money", child: Text("Orange Money")),
              DropdownMenuItem(
                  value: "MTN Mobile Money", child: Text("MTN Mobile Money")),
              DropdownMenuItem(value: "Moov Money", child: Text("Moov Money")),
            ],
            validator: (v) =>
                v != null && v.isNotEmpty ? null : "Sélectionnez un opérateur",
            onChanged: (v) => operator = v ?? '',
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Numéro de téléphone",
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            maxLength: 15,
            validator: (v) =>
                v != null && v.length >= 8 ? null : "Numéro invalide",
            onChanged: (v) => phone = v,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D3CF8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Payer ${widget.ticket['price']} FCFA",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/*import 'dart:ui';
import 'package:abbeav/config/theme/app_colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../style/app_color.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> ticketCategories = [
      {
        'name': 'Canal Olympia',
        'backImage':
            'https://cdn.tripinafrica.com/places/canal-olympia-1740433127.jpg',
        'image':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQgqncKaUAFayALhexeEllosqhVZL88PhAHkg&s',
        'desc':
            'Vivez l’expérience cinéma Canal Olympia. Salle moderne, son immersif, films récents.',
        'places': 120,
        'price': 3500,
      },
      {
        'name': 'Cinema Eden',
        'backImage':
            'https://www.europeanfilmacademy.org/app/uploads/2022/10/eden-cinemas-opening-33.jpg',
        'image':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHcbSZPexi-bXsb9tb0cdNmfR3xVD-qQ4nYw&s',
        //'https://images.unsplash.com/photo-1517602302552-471fe67acf66?auto=format&fit=crop&w=200&q=80',
        'desc':
            'Découvrez le charme du cinéma Eden. Ambiance conviviale, films pour tous.',
        'places': 80,
        'price': 3500,
      },
    ];

    final List<Map<String, dynamic>> ticketsPayed = [
      {
        'date': 'Dec 17 2025',
        'hour': '11:45PM',
        'cinema': 'Canal Olympia',
        'movie': 'The Wars: Episode VVI - The Force Awakens',
        'season': '1',
        'image':
            'https://images.unsplash.com/photo-1517602302552-471fe67acf66?auto=format&fit=crop&w=200&q=80',
        'ticketNumber': 'ABV-20251217-001',
        'price': 3500,
      },
      {
        'date': 'Dec 10 2025',
        'hour': '09:30PM',
        'cinema': 'Cinema Eden',
        'movie': 'Dune: Part Two',
        'season': '2',
        'image':
            'https://images.unsplash.com/photo-1517602302552-471fe67acf66?auto=format&fit=crop&w=200&q=80',
        'ticketNumber': 'ABV-20251210-002',
        'price': 3500,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          children: [
            // --- Pub Carousel ---
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 10),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 170,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
                items: ticketCategories.map((cat) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            cat['backImage'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black.withOpacity(0.18),
                            colorBlendMode: BlendMode.darken,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(18)),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.01),
                                  Colors.black.withOpacity(0.7)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    shadows: [
                                      Shadow(blurRadius: 8, color: Colors.black)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat['desc'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.92),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            // --- Tickets à acheter ---
            ...ticketCategories.map((cat) => _CardTicket(
                  image: cat['image'],
                  name: cat['name'],
                  desc: cat['desc'],
                  places: cat['places'],
                  price: cat['price'],
                )),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                "Moyen de paiement",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.92),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _CardTicket extends StatefulWidget {
  final String image;
  final String name;
  final String desc;
  final int places;
  final int price;

  const _CardTicket({
    required this.image,
    required this.name,
    required this.desc,
    required this.places,
    required this.price,
  });

  @override
  State<_CardTicket> createState() => _CardTicketState();
}

class _CardTicketState extends State<_CardTicket>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.primary, //Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.13),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image catégorie
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(18)),
              child: Image.network(
                widget.image,
                width: 90,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.desc,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event_seat, color: Colors.white70, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.places} places disponibles",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Prix + bouton animé
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${widget.price} FCFA",
                  style: const TextStyle(
                      color: Color(0xFF3DCBFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const SizedBox(height: 10),
                AnimatedBuilder(
                  animation: _gradientAnim,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: const [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [
                            _gradientAnim.value * 0.5,
                            1 - _gradientAnim.value * 0.5
                          ],
                          transform:
                              GradientRotation(_gradientAnim.value * 3.14),
                        ).createShader(bounds);
                      },
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                        ),
                        onPressed: () {
                          // TODO: Action d'achat de ticket
                        },
                        child: const Text(
                          "Acheter",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}*/
