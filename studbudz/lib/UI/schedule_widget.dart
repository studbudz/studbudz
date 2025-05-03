import 'package:flutter/material.dart';

class ScheduleWidget extends StatefulWidget {
  final double? height;
  const ScheduleWidget({super.key, this.height});

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  double currentPage = 0;

  final List<Map<String, dynamic>> eventData = [
    {
      'userId': 1,
      'subjectId': 2,
      'eventName': 'Physics Café at Starbucks',
      'eventImage': 'starbucks_physics_image.jpg',
      'eventDescription':
          "Join us for an intellectually stimulating cup of coffee at Starbucks. Let's talk all things physics, from quantum mechanics to the mysteries of the universe!",
      'eventLocationName': 'Starbucks Café',
      'eventAddress': 'Whiteley Wy, Whiteley, Fareham PO15 7LJ',
      'eventStartAt': DateTime.parse('2025-03-05 10:00:00'),
      'eventEndAt': DateTime.parse('2025-03-05 12:00:00'),
    },
    {
      'userId': 2,
      'subjectId': 5,
      'eventName': 'Computer Science & Coffee at The Isambard',
      'eventImage': 'isambard_computer_science_image.jpg',
      'eventDescription':
          "Come join us at The Isambard Kingdom Brunel in Portsmouth for a great blend of caffeine and computer science talk. Whether you're a coding newbie or a seasoned developer, there's something for everyone!",
      'eventLocationName': 'The Isambard Kingdom Brunel',
      'eventAddress': '2 Guildhall Walk, Portsmouth PO1 2DD',
      'eventStartAt': DateTime.parse('2025-03-06 14:00:00'),
      'eventEndAt': DateTime.parse('2025-03-06 16:00:00'),
    },
    {
      'userId': 4,
      'subjectId': null,
      'eventName': 'Italian Bear Chocolate Meetup',
      'eventImage': 'chocolate_meetup_image.jpg',
      'eventDescription':
          "A casual meetup for all chocolate lovers in the heart of Fitzrovia. Meet new people, chat, and enjoy delicious Italian Bear Chocolate together.",
      'eventLocationName': 'Italian Bear Chocolate',
      'eventAddress': '29 Rathbone Pl, London W1T 1JG',
      'eventStartAt': DateTime.parse('2025-03-07 18:00:00'),
      'eventEndAt': DateTime.parse('2025-03-07 20:00:00'),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page ?? 0;
      });
    });
  }

  void nextPage() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void previousPage() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final double centerY = MediaQuery.of(context).size.height / 2 - 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title at the top, centered
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              "Upcoming Events",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.blue[900],
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Stack for the event cards and navigation buttons
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: eventData.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  double scale =
                      (1.1 - 0.2 * (currentPage - index).abs()).clamp(0.9, 1.1);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Transform.scale(
                      scale: scale,
                      child: Center(
                        child: EventCard(
                            event: eventData[index],
                            height: widget.height ?? 0.5),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 20,
                top: centerY,
                child: IconButton(
                    onPressed: previousPage,
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 30)),
              ),
              Positioned(
                right: 20,
                top: centerY,
                child: IconButton(
                    onPressed: nextPage,
                    icon: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 30)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final double height;

  const EventCard({
    super.key,
    required this.event,
    required this.height,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isFront = true;

  void _flipCard() {
    setState(() {
      isFront = !isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight =
        MediaQuery.of(context).size.height * widget.height;
    final double cardWidth = MediaQuery.of(context).size.height * 0.7;

    return GestureDetector(
      onTap: _flipCard,
      child: SizedBox(
        height: cardHeight,
        width: cardWidth,
        child: isFront ? _buildFront() : _buildBack(),
      ),
    );
  }

  // Front of the card displaying basic information
  Widget _buildFront() {
    String eventName = widget.event['eventName'] ?? 'Event Name';
    String eventLocation = widget.event['eventLocationName'] ?? 'Location';
    DateTime eventStartAt = widget.event['eventStartAt'] ?? DateTime.now();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              eventName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              eventLocation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Starts at: ${eventStartAt.toLocal()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Back of the card showing more detailed information
  Widget _buildBack() {
    String eventDescription =
        widget.event['eventDescription'] ?? 'No description available.';
    String eventAddress = widget.event['eventAddress'] ?? 'Unknown Address';

    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              eventDescription,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Address:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              eventAddress,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
