import 'package:flutter/material.dart';

// Color Scheme
const primaryColor = Color(0xFF1A73E8);
const secondaryColor = Color(0xFF5F6368);
const backgroundColor = Color(0xFFF8F9FA);
const surfaceColor = Colors.white;
const errorColor = Color(0xFFDC3545);
const successColor = Color(0xFF28A745);
const warningColor = Color(0xFFFFC107);

// Text Styles
const headerTextStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Color(0xFF1F2937),
  letterSpacing: -0.5,
);

const subHeaderTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Color(0xFF374151),
  letterSpacing: -0.3,
);

const cardTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F2937),
  letterSpacing: -0.2,
);

const cardSubtitleStyle = TextStyle(
  fontSize: 14,
  color: Color(0xFF6B7280),
  letterSpacing: -0.1,
);

// Responsive Breakpoints
const kTabletBreakpoint = 768.0;
const kDesktopBreakpoint = 1440.0;

// Spacing
const kSpacing = 20.0;
const kSpacingLarge = 32.0;
const kSpacingSmall = 12.0;

// Card Decorations
BoxDecoration get cardDecoration => BoxDecoration(
  color: surfaceColor,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ],
);

// Responsive Layout Helper
bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= kDesktopBreakpoint;
bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= kTabletBreakpoint &&
    MediaQuery.of(context).size.width < kDesktopBreakpoint;
bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < kTabletBreakpoint;

// Widgets
Widget fabButton(VoidCallback onPressed) {
  return FloatingActionButton(
    onPressed: onPressed,
    backgroundColor: primaryColor,
    elevation: 2,
    child: const Icon(Icons.add, color: Colors.white),
  );
}

Widget statsCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: cardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: cardTitleStyle),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ],
        ),
        const SizedBox(height: kSpacingSmall),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            letterSpacing: -1,
          ),
        ),
      ],
    ),
  );
}

Widget recentActivityTile(String activity, String time) {
  return Container(
    margin: const EdgeInsets.only(bottom: kSpacingSmall),
    padding: const EdgeInsets.all(16),
    decoration: cardDecoration.copyWith(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget profileCard({
  required String studentName,
  required String parentName,
  required String age,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: kSpacingSmall),
    decoration: cardDecoration,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_outline,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: kSpacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentName, style: cardTitleStyle),
                    const SizedBox(height: 4),
                    Text(
                      'Parent: $parentName',
                      style: cardSubtitleStyle,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Age: $age',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget quickStatBox(String label, String value, {TextStyle? valueStyle}) {
  return Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
      const SizedBox(height: 4),
      Text(value, style: valueStyle ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ],
  );
}

Widget searchBar({
  required TextEditingController controller,
  required Function(String) onChanged,
  String? hintText, // Accept the hintText parameter
}) {
  return Container(
    decoration: cardDecoration,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText ?? 'Search by student name...', // Use the passed hintText or fallback to default
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
    ),
  );
}


Widget quickLinkCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required VoidCallback onTap,
  Color? iconColor,
}) {
  return Container(
    decoration: cardDecoration,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (iconColor ?? primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: kSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: secondaryColor.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget overviewStatsCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
  String? subtitle,
  VoidCallback? onTap,
}) {
  return Container(
    decoration: cardDecoration,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (onTap != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: secondaryColor,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

Widget sectionHeader({
  required String title,
  String? subtitle,
  Widget? action,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: kSpacing),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: headerTextStyle),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryColor.withOpacity(0.8),
                ),
              ),
          ],
        ),
        if (action != null) action,
      ],
    ),
  );
}
