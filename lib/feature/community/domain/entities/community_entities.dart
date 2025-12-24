class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String phoneNumber;
  final String email;
  final String location;
  final double rating;
  final int experience;
  final String availability;
  final String imageUrl;
  final bool isAvailable;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phoneNumber,
    required this.email,
    required this.location,
    required this.rating,
    required this.experience,
    required this.availability,
    this.imageUrl = '',
    this.isAvailable = true,
  });
}

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorImage;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final List<String> tags;

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorImage,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.tags = const [],
  });
}

class SupportGroup {
  final String id;
  final String name;
  final String description;
  final int members;
  final String category;
  final String meetingTime;

  const SupportGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.category,
    required this.meetingTime,
  });
}
