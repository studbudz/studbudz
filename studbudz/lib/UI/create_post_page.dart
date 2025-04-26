import 'package:flutter/material.dart';
import 'text_form_widget.dart';
import 'media_form_widget.dart';
import 'event_form_widget.dart';
import 'package:studubdz/notifier.dart';

enum PostType { text, media, event }

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  int selector = 0;

  @override
  Widget build(BuildContext context) {
    Controller notifier = Controller();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  notifier.setPage(AppPage.home);
                },
              ),
              Expanded(
                child: Text(
                  'Create Post',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              // To balance the Row, add a SizedBox with same width as IconButton
              const SizedBox(width: 48),
            ],
          ),
        ),
        buildSelector(),
        const SizedBox(
          height: 20,
        ),
        buildForm(),
      ],
    );
  }

  Widget buildSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSelectorButton('Text', 0),
        _buildSelectorButton('Media', 1),
        _buildSelectorButton('Event', 2),
      ],
    );
  }

  Widget _buildSelectorButton(String label, int index) {
    final bool isSelected = selector == index;
    return GestureDetector(
      onTap: () => setState(() => selector = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void submit(dynamic data) {
    Controller controller = Controller();
    controller.engine.createPost(data);
  }

  Widget buildForm() {
    Widget formWidget;
    switch (selector) {
      case 0:
        formWidget = TextFormWidget(
          submit: submit,
        );
        break;
      case 1:
        formWidget = MediaFormWidget(
          submit: submit,
        );
        break;
      case 2:
        formWidget = EventFormWidget(
          submit: submit,
        );
        break;
      default:
        formWidget = const SizedBox.shrink();
    }
    //reduces the size of the subwidget.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: formWidget,
    );
  }
}
