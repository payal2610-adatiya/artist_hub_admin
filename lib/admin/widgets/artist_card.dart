// lib/admin/widgets/artist_card.dart - Updated with loading state
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';

class ArtistCard extends StatelessWidget {
  final String name;
  final String category;
  final double rating;
  final double earnings;
  final bool isPending;
  final VoidCallback? onApprove;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDelete;
  final bool isApproving; // NEW: Add this parameter

  const ArtistCard({
    Key? key,
    required this.name,
    required this.category,
    this.rating = 0.0,
    this.earnings = 0.0,
    this.isPending = false,
    this.onApprove,
    this.onViewDetails,
    this.onDelete,
    this.isApproving = false, // NEW: Default to false
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
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        if (isApproving)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.warningColor),
                            ),
                          )
                        else
                          Icon(Icons.pending, size: 12, color: AppColors.warningColor),
                        const SizedBox(width: 4),
                        Text(
                          isApproving ? 'Approving...' : 'Pending',
                          style: TextStyle(
                            color: AppColors.warningColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (rating > 0)
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.gold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                Expanded(
                  child: Text(
                    earnings > 0 ? Helpers.formatCurrency(earnings) : 'Price not set',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: earnings > 0 ? AppColors.primaryColor : AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isPending && onApprove != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isApproving ? null : onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isApproving
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Approve',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (isPending && onApprove != null) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPending ? AppColors.primaryColor.withOpacity(0.1) : AppColors.primaryColor,
                      foregroundColor: isPending ? AppColors.primaryColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isPending ? 'View Details' : 'Manage',
                    ),
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    child: ElevatedButton(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorColor.withOpacity(0.1),
                        foregroundColor: AppColors.errorColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.delete, size: 20),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}