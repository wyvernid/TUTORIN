class ChatMessage {
  final String id, senderId, senderNama, text;
  final String? fileUrl;
  // 'image' | 'pdf' | null (pesan teks biasa)
  final String? fileType;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderNama,
    required this.text,
    this.fileUrl,
    this.fileType,
    required this.createdAt,
    this.isRead = false,
  });

  bool get isImage => fileType == 'image';
  bool get isPdf   => fileType == 'pdf';

  factory ChatMessage.fromMap(Map<String, dynamic> m, String id) => ChatMessage(
    id: id,
    senderId:   m["senderId"]   ?? "",
    senderNama: m["senderNama"] ?? "",
    text:       m["text"]       ?? "",
    fileUrl:    m["fileUrl"],
    fileType:   m["fileType"],
    createdAt:  m["createdAt"] != null
        ? (m["createdAt"] as dynamic).toDate()
        : DateTime.now(),
    isRead: m["isRead"] ?? false,
  );

  Map<String, dynamic> toMap() => {
    "senderId":   senderId,
    "senderNama": senderNama,
    "text":       text,
    "fileUrl":    fileUrl,
    "fileType":   fileType,
    "createdAt":  createdAt,
    "isRead":     isRead,
  };
}

class ChatRoom {
  final String id, lastMessage;
  final List<String> members;
  final Map<String, String> memberNames, memberRoles;
  final Map<String, int> unreadCount;
  final DateTime lastMessageAt;

  ChatRoom({
    required this.id,
    required this.lastMessage,
    required this.members,
    required this.memberNames,
    this.memberRoles = const {},
    required this.unreadCount,
    required this.lastMessageAt,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> m, String id) => ChatRoom(
    id:            id,
    lastMessage:   m["lastMessage"]   ?? "",
    members:       List<String>.from(m["members"] ?? []),
    memberNames:   Map<String, String>.from(m["memberNames"] ?? {}),
    memberRoles:   Map<String, String>.from(m["memberRoles"] ?? {}),
    unreadCount:   Map<String, int>.from(m["unreadCount"] ?? {}),
    lastMessageAt: m["lastMessageAt"] != null
        ? (m["lastMessageAt"] as dynamic).toDate()
        : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    "lastMessage":   lastMessage,
    "members":       members,
    "memberNames":   memberNames,
    "memberRoles":   memberRoles,
    "unreadCount":   unreadCount,
    "lastMessageAt": lastMessageAt,
  };
}