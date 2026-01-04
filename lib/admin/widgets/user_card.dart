// lib/admin/widgets/user_card.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';

class UserCard extends StatelessWidget {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final bool isApproved;
  final DateTime createdAt;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetails;
  final VoidCallback? onToggleStatus; // NEW: Add this


  const UserCard({
    Key? key,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.isApproved,
    required this.createdAt,
    this.onDelete,
    this.onViewDetails,
    this.onToggleStatus
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      color: _getRoleColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Text(
                  'Joined: ${Helpers.formatDate(createdAt)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.successColor.withOpacity(0.1)
                        : AppColors.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.successColor : AppColors.errorColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (role == 'artist')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? AppColors.successColor.withOpacity(0.1)
                          : AppColors.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isApproved ? 'APPROVED' : 'PENDING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isApproved ? AppColors.successColor : AppColors.warningColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // In the button section of the build method, add:
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text('View Details', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                if (onToggleStatus != null)
                  SizedBox(
                    width: 50,
                    child: ElevatedButton(
                      onPressed: onToggleStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? AppColors.warningColor : AppColors.successColor,
                      ),
                      child: Icon(
                        isActive ? Icons.pause : Icons.play_arrow,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (onDelete != null)
                  SizedBox(
                    width: 50,
                    child: ElevatedButton(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorColor,
                      ),
                      child: const Icon(Icons.delete, size: 20, color: Colors.white),
                    ),
                  ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Color _getRoleColor() {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.errorColor;
      case 'artist':
        return AppColors.gold;
      case 'customer':
        return AppColors.primaryColor;
      default:
        return AppColors.grey;
    }
  }
}