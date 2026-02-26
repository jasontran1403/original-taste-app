import 'dart:async';

import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/utils/generator.dart';
import 'package:original_taste/models/chat_model.dart';

class ChatController extends MyController {
  // Chat data
  List<ChatModel> chat = [];
  List<ChatModel> searchChat = [];
  ChatModel? selectedChat;

  // UI and interaction
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final SearchController searchController = SearchController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Timer & time text
  Timer? _timer;
  int _elapsedSeconds = 0;
  String timeText = "00 : 00";

  // Typing status
  Timer? typingTimer;
  bool isTyping = false;
  String? typingUserId;

  // Navigation
  int currentIndex = 0;

  // Groups
  final List<Groups> group = [
    Groups(name: "General"),
    Groups(name: "Company", badge: 33),
    Groups(name: "Life Suckers", badge: 17),
    Groups(name: "Drama Club"),
    Groups(name: "Unknown Friends"),
    Groups(name: "Family Ties", badge: 65),
    Groups(name: "2Good4U"),
  ];

  @override
  void onInit() {
    super.onInit();

    // Load chat data
    ChatModel.dummyList.then((value) {
      chat = value;
      searchChat = List.from(value);
      selectedChat = chat.isNotEmpty ? chat.first : null;
      update();
    });
  }

  /// Triggered when the user types a message
  void onTyping() {
    if (!isTyping) {
      isTyping = true;
      update();
    }

    typingTimer?.cancel();
    typingTimer = Timer(const Duration(milliseconds: 300), () {
      isTyping = false;
      update();
    });
  }

  /// Updates which user is typing
  void setTypingUser(String? userId) {
    typingUserId = userId;
    update();
  }

  /// Search chat based on user input
  void onSearchChat(String query) {
    final lowerQuery = query.toLowerCase();
    searchChat = chat.where((item) => item.firstName.toLowerCase().contains(lowerQuery)).toList();
    update();
  }

  /// Send a message in selected chat
  void sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isNotEmpty && selectedChat != null) {
      selectedChat!.messages.add(
        ChatMessageModel(-1, messageText, DateTime.now(), true),
      );
      messageController.clear();
      scrollToBottom(isDelayed: true);
      update();
    }
  }

  /// Scroll to bottom of the chat
  void scrollToBottom({bool isDelayed = false}) {
    Future.delayed(Duration(milliseconds: isDelayed ? 400 : 0), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubicEmphasized,
        );
      }
    });
  }

  /// Change selected chat
  void onChangeChat(ChatModel chatItem) {
    selectedChat = chatItem;
    update();
  }

  /// Change the selected index for the bottom navigation
  void onChangeIndex(int index) {
    currentIndex = index;
    update();
  }

  /// Starts the in-chat timer
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      timeText = Generator.getTextFromSeconds(time: _elapsedSeconds);
      update();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    typingTimer?.cancel();
    scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }
}

class Groups {
  final String name;
  final int badge;

  Groups({required this.name, this.badge = 0});
}
