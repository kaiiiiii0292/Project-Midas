import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlexShareTheme {
  static const navy = Color(0xFF1E3A8A);
  static const teal = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const canvas = Color(0xFFF8FAFC);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navy,
          primary: navy,
          secondary: teal,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: canvas,
          foregroundColor: ink,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: navy, width: 1.5),
          ),
        ),
      );
}

class RentalItem {
  RentalItem({
    required this.id,
    required this.name,
    required this.category,
    required this.hourlyRate,
    required this.dailyRate,
    required this.owner,
    required this.location,
    required this.icon,
    this.description = 'Well cared for and ready for your next class project.',
    this.rating = 4.9,
    this.isOwned = false,
  });

  final String id;
  final String name;
  final String category;
  final int hourlyRate;
  final int dailyRate;
  final String owner;
  final String location;
  final IconData icon;
  final String description;
  final double rating;
  final bool isOwned;
}

class RentalBooking {
  RentalBooking({
    required this.item,
    required this.duration,
    required this.hourly,
    required this.withRunner,
    required this.protection,
  });

  final RentalItem item;
    final int duration;
    final bool hourly;
  final bool withRunner;
  final bool protection;
  bool pickupComplete = false;
  bool returnComplete = false;

    int get rentalSubtotal =>
      (hourly ? item.hourlyRate : item.dailyRate) * duration;

    int get total =>
      rentalSubtotal +
      (protection ? (rentalSubtotal * 0.05).ceil() : 0) +
      (withRunner ? 20 : 0);

    String get durationLabel =>
      '$duration ${hourly ? (duration == 1 ? 'hour' : 'hours') : (duration == 1 ? 'day' : 'days')}';
}

class FlexShareApp extends StatefulWidget {
  const FlexShareApp({super.key});

  @override
  State<FlexShareApp> createState() => _FlexShareAppState();
}

class _FlexShareAppState extends State<FlexShareApp> {
  int _tab = 0;
  String _category = 'All';
  String _query = '';
  final _searchController = TextEditingController();
  final _items = <RentalItem>[
    RentalItem(
      id: 'calc',
      name: 'Casio fx-991EX ClassWiz',
      category: 'Calculators',
      hourlyRate: 8,
      dailyRate: 45,
      owner: 'Mika R.',
      location: 'Science and Computer Lab (#10)',
      icon: Icons.calculate_outlined,
    ),
    RentalItem(
      id: 'camera',
      name: 'Canon EOS 200D II',
      category: 'Cameras',
      hourlyRate: 65,
      dailyRate: 380,
      owner: 'Andre C.',
      location: 'Central Library (#3)',
      icon: Icons.camera_alt_outlined,
      description: 'Includes a kit lens, battery, and a 16 GB memory card.',
    ),
    RentalItem(
      id: 'tablet',
      name: 'Wacom One Drawing Tablet',
      category: 'Drawing tools',
      hourlyRate: 35,
      dailyRate: 180,
      owner: 'Bea L.',
      location: 'Architecture Building (#32)',
      icon: Icons.draw_outlined,
    ),
    RentalItem(
      id: 'arduino',
      name: 'Arduino Uno Starter Kit',
      category: 'Electronics',
      hourlyRate: 25,
      dailyRate: 140,
      owner: 'Paolo M.',
      location: 'Information Technology (#17)',
      icon: Icons.memory_outlined,
      rating: 5.0,
    ),
    RentalItem(
      id: 'labcoat',
      name: 'Lab coat - size M',
      category: 'Lab gear',
      hourlyRate: 12,
      dailyRate: 70,
      owner: 'Nica P.',
      location: 'College of Science (#8)',
      icon: Icons.science_outlined,
    ),
  ];
  final _bookings = <RentalBooking>[];

  static const _categories = [
    'All',
    'Calculators',
    'Cameras',
    'Drawing tools',
    'Electronics',
    'Lab gear',
  ];

  List<RentalItem> get _visibleItems => _items.where((item) {
        final matchesCategory = _category == 'All' || item.category == _category;
        final matchesQuery =
            '${item.name} ${item.category} ${item.location} ${item.owner}'
                .toLowerCase()
                .contains(_query.toLowerCase());
        return matchesCategory && matchesQuery;
      }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectTab(int value) {
    setState(() => _tab = value);
  }

  Future<void> _openItem(RentalItem item) async {
    final booking = await showModalBottomSheet<RentalBooking>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemDetailsSheet(item: item),
    );
    if (booking == null || !mounted) return;
    setState(() {
      _bookings.insert(0, booking);
      _tab = 3;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request sent for ${item.name}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: FlexShareTheme.ink,
      ),
    );
  }

  void _addListing(RentalItem item) {
    setState(() {
      _items.insert(0, item);
      _tab = 0;
      _category = 'All';
      _query = '';
      _searchController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your item is now listed on campus'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildBrowse(),
      _buildCampusMap(),
      _CreateListingPage(onSubmit: _addListing),
      _ActivityPage(bookings: _bookings),
      const _ProfilePage(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        backgroundColor: Colors.white,
        indicatorColor: FlexShareTheme.teal.withOpacity(0.13),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Campus map',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            label: 'List item',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBrowse() {
    final items = _visibleItems;
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/flexshare_logo.svg',
                      key: const ValueKey('flexshare-logo'),
                      width: 140,
                      height: 70,
                      fit: BoxFit.contain,
                      semanticsLabel: 'FlexShare',
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Your activity',
                      onPressed: () => _selectTab(3),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'PALAWAN STATE UNIVERSITY',
                  style: TextStyle(
                    color: FlexShareTheme.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'What do you need\nfor class?',
                  style: TextStyle(
                    color: FlexShareTheme.ink,
                    fontSize: 29,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search calculators, cameras, lab gear...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 17),
                _RunnerBanner(onTap: () => _selectTab(1)),
                const SizedBox(height: 19),
                const _SectionHeading(
                  title: 'Browse by need',
                  trailing: 'See all',
                ),
                const SizedBox(height: 11),
                SizedBox(
                  height: 39,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final selected = category == _category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) => setState(() => _category = category),
                        selectedColor: FlexShareTheme.navy,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : FlexShareTheme.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: selected
                              ? FlexShareTheme.navy
                              : const Color(0xFFE2E8F0),
                        ),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 21),
                _SectionHeading(
                  title: _query.isNotEmpty || _category != 'All'
                      ? 'Matching equipment'
                      : 'Available nearby',
                  trailing: '${items.length} items',
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No equipment found',
              message: 'Try another search or category.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ListingCard(
                    item: items[index],
                    onTap: () => _openItem(items[index]),
                  ),
                ),
                childCount: items.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCampusMap() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PALAWAN STATE UNIVERSITY',
                      style: TextStyle(
                        color: FlexShareTheme.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Main campus map',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: FlexShareTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _tab = 0),
                icon: const Icon(Icons.list_rounded),
                label: const Text('List'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _CampusMapCanvas(
            items: _items,
            onItemTap: _openItem,
          ),
        ),
      ],
    );
  }

}

class _RunnerBanner extends StatelessWidget {
  const _RunnerBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlexShareTheme.navy,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          height: 97,
          child: Stack(
            children: [
              Positioned(
                right: -4,
                top: -17,
                child: Icon(
                  Icons.delivery_dining_rounded,
                  size: 125,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IN-BETWEEN CLASSES? EARN.',
                      style: TextStyle(
                        color: Color(0xFFB6F4DE),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Become a FlexRunner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Deliver between buildings - from P20',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 13,
                bottom: 13,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: FlexShareTheme.ink,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: FlexShareTheme.muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.item, required this.onTap});

  final RentalItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(
            children: [
              _ItemIllustration(item: item, size: 76),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        color: FlexShareTheme.teal,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: FlexShareTheme.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 13, color: FlexShareTheme.muted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: FlexShareTheme.muted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const Icon(Icons.star_rounded,
                            size: 13, color: FlexShareTheme.amber),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: FlexShareTheme.ink,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          'P${item.hourlyRate}',
                          style: const TextStyle(
                            color: FlexShareTheme.navy,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          ' / hour',
                          style: TextStyle(
                            color: FlexShareTheme.muted,
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.isOwned ? 'Your listing' : 'by ${item.owner}',
                          style: const TextStyle(
                            color: FlexShareTheme.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemIllustration extends StatelessWidget {
  const _ItemIllustration({required this.item, required this.size});

  final RentalItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = switch (item.category) {
      'Calculators' => const [Color(0xFFE0E7FF), Color(0xFFBFDBFE)],
      'Cameras' => const [Color(0xFFFFEDD5), Color(0xFFFDE68A)],
      'Drawing tools' => const [Color(0xFFCCFBF1), Color(0xFFA7F3D0)],
      'Electronics' => const [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
      _ => const [Color(0xFFFFEDD5), Color(0xFFFED7AA)],
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(item.icon, size: size * 0.47, color: FlexShareTheme.navy),
    );
  }
}

class _ItemDetailsSheet extends StatefulWidget {
  const _ItemDetailsSheet({required this.item});

  final RentalItem item;

  @override
  State<_ItemDetailsSheet> createState() => _ItemDetailsSheetState();
}

class _ItemDetailsSheetState extends State<_ItemDetailsSheet> {
  int _duration = 1;
  bool _hourly = false;
  bool _runner = false;
  bool _protection = true;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final rental = (_hourly ? item.hourlyRate : item.dailyRate) * _duration;
    final protection = _protection ? (rental * 0.05).ceil() : 0;
    final delivery = _runner ? 20 : 0;
    final total = rental + protection + delivery;
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          11,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _ItemIllustration(item: item, size: 88),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            color: FlexShareTheme.teal,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: FlexShareTheme.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'P${item.hourlyRate}/hour  |  P${item.dailyRate}/day',
                          style: const TextStyle(
                            color: FlexShareTheme.navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                item.description,
                style: const TextStyle(
                  color: FlexShareTheme.muted,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 15),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Hourly')),
                  ButtonSegment(value: false, label: Text('Daily')),
                ],
                selected: {_hourly},
                onSelectionChanged: (selection) => setState(() {
                  _hourly = selection.first;
                  _duration = 1;
                }),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Rental length',
                      style: TextStyle(
                        color: FlexShareTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _duration > 1
                        ? () => setState(() => _duration--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: FlexShareTheme.navy,
                  ),
                  Text(
                    '$_duration ${_hourly ? (_duration == 1 ? 'hour' : 'hours') : (_duration == 1 ? 'day' : 'days')}',
                  ),
                  IconButton(
                    onPressed: _duration < (_hourly ? 12 : 7)
                        ? () => setState(() => _duration++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: FlexShareTheme.navy,
                  ),
                ],
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _runner,
                activeColor: FlexShareTheme.teal,
                onChanged: (value) => setState(() => _runner = value),
                title: const Text(
                  'FlexRunner delivery',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Meet your courier at your building - P20'),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _protection,
                activeColor: FlexShareTheme.teal,
                onChanged: (value) => setState(() => _protection = value),
                title: const Text(
                  'Accidental damage protection',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                subtitle: Text('5% of rental - P$protection'),
              ),
              const Divider(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Estimated total',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    'P$total',
                    style: const TextStyle(
                      color: FlexShareTheme.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 21,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: item.isOwned
                      ? null
                      : () => Navigator.pop(
                            context,
                            RentalBooking(
                              item: item,
                              duration: _duration,
                              hourly: _hourly,
                              withRunner: _runner,
                              protection: _protection,
                            ),
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: FlexShareTheme.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(item.isOwned ? 'Your listing' : 'Request to rent'),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _CampusMapCanvas extends StatelessWidget {
  const _CampusMapCanvas({required this.items, required this.onItemTap});

  final List<RentalItem> items;
  final ValueChanged<RentalItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: LayoutBuilder(
              builder: (context, constraints) => InteractiveViewer(
                minScale: 1,
                maxScale: 2.8,
                boundaryMargin: const EdgeInsets.all(28),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: CustomPaint(painter: _CampusMapPainter()),
                        ),
                        Positioned(
                          left: 10,
                          top: 10,
                          child: _MapLabel(
                            icon: Icons.account_balance_outlined,
                            label: 'PSU MAIN CAMPUS',
                          ),
                        ),
                        for (final item in items)
                          if (_mapPositions.containsKey(item.id))
                            Positioned(
                              left: constraints.maxWidth *
                                  _mapPositions[item.id]!.dx,
                              top: constraints.maxHeight *
                                  _mapPositions[item.id]!.dy,
                              child: _MapItemPin(
                                icon: item.icon,
                                label: 'P${item.hourlyRate}/h',
                                onTap: () => onItemTap(item),
                              ),
                            ),
                        const Positioned(
                          right: 10,
                          top: 10,
                          child: _MapLabel(
                            icon: Icons.login_rounded,
                            label: 'MAIN GATE',
                            accent: true,
                          ),
                        ),
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: _MapLabel(
                            icon: Icons.layers_outlined,
                            label: '${items.length} RENTABLE ITEMS',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 174,
          color: Colors.white,
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Available on this map',
                        style: TextStyle(
                          color: FlexShareTheme.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${items.length} listings',
                      style: const TextStyle(
                        color: FlexShareTheme.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (context, index) => _MapListingCard(
                    item: items[index],
                    onTap: () => onItemTap(items[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const _mapPositions = <String, Offset>{
    'calc': Offset(0.59, 0.29),
    'camera': Offset(0.37, 0.39),
    'tablet': Offset(0.22, 0.69),
    'arduino': Offset(0.49, 0.34),
    'labcoat': Offset(0.68, 0.25),
  };
}

class _MapItemPin extends StatelessWidget {
  const _MapItemPin({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlexShareTheme.teal,
      borderRadius: BorderRadius.circular(9),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: accent ? FlexShareTheme.amber : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: accent ? FlexShareTheme.amber : FlexShareTheme.navy,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: FlexShareTheme.ink,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapListingCard extends StatelessWidget {
  const _MapListingCard({required this.item, required this.onTap});

  final RentalItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlexShareTheme.canvas,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Row(
              children: [
                _ItemIllustration(item: item, size: 52),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: FlexShareTheme.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: FlexShareTheme.muted,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'P${item.hourlyRate} / hour',
                        style: const TextStyle(
                          color: FlexShareTheme.navy,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: FlexShareTheme.muted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CampusMapPainter extends CustomPainter {
  const _CampusMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.src);
    final roadPaint = Paint()
      ..color = const Color(0xFF85878B)
      ..strokeWidth = size.shortestSide * 0.055
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mainRoad = Path()
      ..moveTo(size.width * 0.02, size.height * 0.19)
      ..lineTo(size.width * 0.78, size.height * 0.19)
      ..cubicTo(size.width * 0.85, size.height * 0.19, size.width * 0.85,
          size.height * 0.31, size.width * 0.92, size.height * 0.37)
      ..cubicTo(size.width * 0.96, size.height * 0.49, size.width * 0.82,
          size.height * 0.68, size.width * 0.73, size.height * 0.80)
      ..cubicTo(size.width * 0.62, size.height * 0.86, size.width * 0.44,
          size.height * 0.78, size.width * 0.34, size.height * 0.73)
      ..cubicTo(size.width * 0.24, size.height * 0.67, size.width * 0.25,
          size.height * 0.54, size.width * 0.32, size.height * 0.45)
      ..lineTo(size.width * 0.36, size.height * 0.19);
    canvas.drawPath(mainRoad, roadPaint);

    final crossRoad = Path()
      ..moveTo(size.width * 0.03, size.height * 0.48)
      ..lineTo(size.width * 0.91, size.height * 0.48)
      ..moveTo(size.width * 0.08, size.height * 0.31)
      ..lineTo(size.width * 0.81, size.height * 0.31)
      ..moveTo(size.width * 0.40, size.height * 0.61)
      ..lineTo(size.width * 0.88, size.height * 0.61)
      ..moveTo(size.width * 0.16, size.height * 0.61)
      ..lineTo(size.width * 0.34, size.height * 0.61)
      ..moveTo(size.width * 0.52, size.height * 0.19)
      ..lineTo(size.width * 0.51, size.height * 0.45);
    canvas.drawPath(crossRoad, roadPaint);

    final buildingPositions = <Offset>[
      const Offset(.83, .42), const Offset(.80, .52), const Offset(.70, .49),
      const Offset(.77, .61), const Offset(.72, .72), const Offset(.64, .42),
      const Offset(.64, .32), const Offset(.65, .25), const Offset(.78, .30),
      const Offset(.64, .22), const Offset(.83, .17), const Offset(.72, .12),
      const Offset(.63, .12), const Offset(.55, .12), const Offset(.49, .12),
      const Offset(.48, .16), const Offset(.52, .21), const Offset(.49, .30),
      const Offset(.45, .40), const Offset(.34, .40), const Offset(.32, .29),
      const Offset(.34, .22), const Offset(.24, .19), const Offset(.20, .27),
      const Offset(.28, .30), const Offset(.22, .37), const Offset(.19, .43),
      const Offset(.15, .50), const Offset(.29, .49), const Offset(.41, .50),
      const Offset(.29, .58), const Offset(.14, .68), const Offset(.36, .75),
      const Offset(.26, .82), const Offset(.37, .87), const Offset(.28, .95),
      const Offset(.44, .96), const Offset(.59, .88), const Offset(.61, .73),
      const Offset(.75, .68), const Offset(.84, .60), const Offset(.92, .54),
      const Offset(.92, .44), const Offset(.89, .39), const Offset(.16, .65),
      const Offset(.10, .35), const Offset(.12, .27), const Offset(.04, .32),
    ];
    final buildingPaint = Paint()..color = const Color(0xFFF4512A);
    final borderPaint = Paint()
      ..color = const Color(0xFFFFB28D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final blockWidth = size.width * .055;
    final blockHeight = size.height * .052;
    for (var index = 0; index < buildingPositions.length; index++) {
      final position = buildingPositions[index];
      final rect = Rect.fromLTWH(
        size.width * position.dx,
        size.height * position.dy,
        blockWidth,
        blockHeight,
      );
      canvas.drawRect(rect, buildingPaint);
      canvas.drawRect(rect, borderPaint);
      final number = TextPainter(
        text: TextSpan(
          text: '${index + 1}',
          style: TextStyle(
            color: index == 22 || index == 31 ? FlexShareTheme.ink : Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: blockWidth);
      number.paint(
        canvas,
        Offset(
          rect.center.dx - number.width / 2,
          rect.center.dy - number.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CreateListingPage extends StatefulWidget {
  const _CreateListingPage({required this.onSubmit});

  final ValueChanged<RentalItem> onSubmit;

  @override
  State<_CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<_CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hourController = TextEditingController();
  final _dayController = TextEditingController();
  String _category = 'Calculators';
  String _location = 'Engineering Building';

  static const _locations = [
    'Engineering Building',
    'Library Annex',
    'Science Complex',
    'College of Architecture',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _hourController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  IconData get _categoryIcon => switch (_category) {
        'Calculators' => Icons.calculate_outlined,
        'Cameras' => Icons.camera_alt_outlined,
        'Drawing tools' => Icons.draw_outlined,
        'Electronics' => Icons.memory_outlined,
        _ => Icons.science_outlined,
      };

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      RentalItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _category,
        hourlyRate: int.parse(_hourController.text),
        dailyRate: int.parse(_dayController.text),
        owner: 'You',
        location: _location,
        icon: _categoryIcon,
        isOwned: true,
      ),
    );
    _nameController.clear();
    _hourController.clear();
    _dayController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 21, 20, 24),
        children: [
          const Text(
            'EARN FROM\nYOUR GEAR.',
            style: TextStyle(
              color: FlexShareTheme.ink,
              fontSize: 29,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'List an item for your campus community.',
            style: TextStyle(color: FlexShareTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Container(
            height: 115,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_categoryIcon, color: FlexShareTheme.navy, size: 44),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CAMPUS-VERIFIED',
                      style: TextStyle(
                        color: FlexShareTheme.teal,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Share more.\nEarn on your schedule.',
                      style: TextStyle(
                        color: FlexShareTheme.ink,
                        fontSize: 17,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Item name'),
          const SizedBox(height: 7),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'e.g. Scientific calculator'),
            validator: (value) => value == null || value.trim().length < 3
                ? 'Enter an item name'
                : null,
          ),
          const SizedBox(height: 15),
          const _FieldLabel('Category'),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(),
            items: _categoriesWithoutAll
                .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 15),
          const _FieldLabel('Pickup location'),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            value: _location,
            decoration: const InputDecoration(),
            items: _locations
                .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) => setState(() => _location = value!),
          ),
          const SizedBox(height: 15),
          const _FieldLabel('Rental price (PHP)'),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _hourController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(prefixText: 'P ', hintText: 'Per hour'),
                  validator: _validatePrice,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _dayController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(prefixText: 'P ', hintText: 'Per day'),
                  validator: _validatePrice,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Publish listing'),
              style: FilledButton.styleFrom(
                backgroundColor: FlexShareTheme.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validatePrice(String? value) {
    final price = int.tryParse(value ?? '');
    return price == null || price <= 0 ? 'Enter a price' : null;
  }

  static const _categoriesWithoutAll = [
    'Calculators',
    'Cameras',
    'Drawing tools',
    'Electronics',
    'Lab gear',
  ];
}

class _ActivityPage extends StatefulWidget {
  const _ActivityPage({required this.bookings});

  final List<RentalBooking> bookings;

  @override
  State<_ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<_ActivityPage> {
  Future<void> _advanceBooking(RentalBooking booking) async {
    final isReturn = booking.pickupComplete;
    final completed = await showDialog<bool>(
      context: context,
      builder: (_) => _HandoffDialog(item: booking.item, isReturn: isReturn),
    );
    if (completed != true || !mounted) return;
    setState(() {
      if (isReturn) {
        booking.returnComplete = true;
      } else {
        booking.pickupComplete = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR RENTALS',
                  style: TextStyle(
                    color: FlexShareTheme.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Activity',
                  style: TextStyle(
                    color: FlexShareTheme.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.bookings.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Nothing rented yet',
              message: 'Your rental requests and handoff details will show up here.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final booking = widget.bookings[index];
                  final status = booking.returnComplete
                      ? 'Rental complete'
                      : booking.pickupComplete
                          ? 'Checked out - return QR needed'
                          : 'Request sent - pickup QR needed';
                  return Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _ItemIllustration(item: booking.item, size: 60),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: FlexShareTheme.ink,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '$status - ${booking.durationLabel}',
                                  style: const TextStyle(
                                    color: FlexShareTheme.teal,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.more_horiz_rounded,
                              color: FlexShareTheme.muted),
                        ],
                      ),
                      const Divider(height: 21),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 15, color: FlexShareTheme.muted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking.withRunner
                                  ? 'FlexRunner delivery requested'
                                  : 'Meet at ${booking.item.location}',
                              style: const TextStyle(
                                color: FlexShareTheme.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            'P${booking.total}',
                            style: const TextStyle(
                              color: FlexShareTheme.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (!booking.returnComplete) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: () => _advanceBooking(booking),
                            icon: const Icon(Icons.qr_code_scanner_rounded,
                                size: 18),
                            label: Text(booking.pickupComplete
                                ? 'Scan return QR'
                                : 'Scan pickup QR'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: FlexShareTheme.navy,
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  );
                },
                childCount: widget.bookings.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _HandoffDialog extends StatefulWidget {
  const _HandoffDialog({required this.item, required this.isReturn});

  final RentalItem item;
  final bool isReturn;

  @override
  State<_HandoffDialog> createState() => _HandoffDialogState();
}

class _HandoffDialogState extends State<_HandoffDialog> {
  bool _photoCaptured = false;

  @override
  Widget build(BuildContext context) {
    final action = widget.isReturn ? 'return' : 'pickup';
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(widget.isReturn ? 'Return handoff' : 'Pickup handoff'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: FlexShareTheme.ink,
              size: 116,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            widget.item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            'Both students scan this QR to confirm the $action.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: FlexShareTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => setState(() => _photoCaptured = true),
            icon: Icon(
              _photoCaptured ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
              size: 18,
            ),
            label: Text(_photoCaptured
                ? 'Condition photo added'
                : 'Capture condition photo'),
          ),
          if (_photoCaptured)
            const Text(
              'Photo proof attached to this handoff',
              style: TextStyle(color: FlexShareTheme.teal, fontSize: 10),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _photoCaptured ? () => Navigator.pop(context, true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: FlexShareTheme.navy,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.isReturn ? 'Confirm return' : 'Confirm pickup'),
        ),
      ],
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Text(
          'YOUR CAMPUS ACCOUNT',
          style: TextStyle(
            color: FlexShareTheme.muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Profile',
          style: TextStyle(
            color: FlexShareTheme.ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FlexShareTheme.navy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: Color(0xFFDBEAFE),
                child: Text(
                  'ST',
                  style: TextStyle(
                    color: FlexShareTheme.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PSU Student',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Palawan State University',
                      style: TextStyle(color: Color(0xFFDCE6FF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.verified_rounded, color: FlexShareTheme.teal),
            ],
          ),
        ),
        const SizedBox(height: 17),
        const _ProfileTile(
          icon: Icons.verified_user_outlined,
          title: 'Student ID verification',
          subtitle: 'Demo profile - connect school ID to verify',
          trailing: Icons.chevron_right_rounded,
        ),
        const _ProfileTile(
          icon: Icons.payments_outlined,
          title: 'Payouts and earnings',
          subtitle: 'Manage your rental and runner earnings',
          trailing: Icons.chevron_right_rounded,
        ),
        const _ProfileTile(
          icon: Icons.shield_outlined,
          title: 'Protection and handoffs',
          subtitle: 'QR check-in - condition photos - protection',
          trailing: Icons.chevron_right_rounded,
        ),
        const _ProfileTile(
          icon: Icons.help_outline_rounded,
          title: 'Help center',
          subtitle: 'Get support with a rental',
          trailing: Icons.chevron_right_rounded,
        ),
        const SizedBox(height: 16),
        const Text(
          'FlexShare prototype - Campus-only marketplace',
          textAlign: TextAlign.center,
          style: TextStyle(color: FlexShareTheme.muted, fontSize: 10),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Icon(icon, color: FlexShareTheme.navy),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10)),
      trailing: Icon(trailing, color: FlexShareTheme.muted),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: FlexShareTheme.ink,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF94A3B8), size: 38),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: FlexShareTheme.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: FlexShareTheme.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}