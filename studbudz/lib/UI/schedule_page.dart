import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
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
      'eventCity': 'Fareham',
      'eventState': 'Hampshire',
      'eventCountry': 'United Kingdom',
      'eventPostalCode': 'PO15 7LJ',
      'eventLatitude': 50.885417,
      'eventLongitude': -1.245500,
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
      'eventCity': 'Portsmouth',
      'eventState': 'Hampshire',
      'eventCountry': 'United Kingdom',
      'eventPostalCode': 'PO1 2DD',
      'eventLatitude': 50.796917,
      'eventLongitude': -1.092528,
      'eventStartAt': DateTime.parse('2025-03-06 14:00:00'),
      'eventEndAt': DateTime.parse('2025-03-06 16:00:00'),
    },
    {
      'userId': 4,
      'subjectId': null,
      'eventName': 'Italian Bear Chocolate Meetup',
      'eventImage': 'chocolate_meetup_image.jpg',
      'eventDescription':
          "A casual meetup for all chocolate lovers in the heart of Fitzrovia. Meet new people, chat, and enjoy delicious Italian Bear Chocolate together. Let's make it a sweet day in London!",
      'eventLocationName': 'Italian Bear Chocolate',
      'eventAddress': '29 Rathbone Pl, London W1T 1JG',
      'eventCity': 'London',
      'eventState': 'England',
      'eventCountry': 'United Kingdom',
      'eventPostalCode': 'W1T 1JG',
      'eventLatitude': 51.517889,
      'eventLongitude': -0.134472,
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
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: eventData.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            //creates a linear curve with a peak at 1.1
            double scale =
                (1.1 - 0.2 * (currentPage - index).abs()).clamp(0.9, 1.1);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.8),
              child: Transform.scale(
                scale: scale,
                child: Center(
                  child: EventCard(event: eventData[index]),
                ),
              ),
            );
          },
        ),
        Positioned(
          left: 20,
          top: centerY,
          child: IconButton(
              onPressed: previousPage, icon: const Icon(Icons.arrow_back)),
        ),
        Positioned(
          right: 20,
          top: centerY,
          child: IconButton(
              onPressed: nextPage, icon: const Icon(Icons.arrow_forward)),
        ),
      ],
    );
  }
}

class EventCard extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventCard({super.key, required this.event});

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
    final double cardHeight = MediaQuery.of(context).size.height * 0.7;
    final double cardWidth = MediaQuery.of(context).size.height * 0.7;
    return GestureDetector(
      onTap: _flipCard,
      child: SizedBox(
          height: cardHeight,
          width: cardWidth,
          child: isFront ? _buildFront() : _buildBack()),
    );
  }
}

Widget _buildFront() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(child: Text('hello')),
  );
}

Widget _buildBack() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text('hiLo'),
  );
}
