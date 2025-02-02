import 'package:scusocial/features/friends/friend-repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendProvider = Provider((ref) {
  return FriendRepository();
});