part of '../../../app.dart';

class FoodsScreen extends ConsumerStatefulWidget {
  const FoodsScreen({super.key});

  @override
  ConsumerState<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends ConsumerState<FoodsScreen> {
  final search = TextEditingController();
  String query = '';
  Timer? debounce;

  @override
  void dispose() {
    debounce?.cancel();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foods = ref.watch(foodsControllerProvider(query));
    return AppShell(
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          HeaderRow(title: 'Foods', subtitle: 'Search foods from the database'),
          const SizedBox(height: 16),
          TextField(
            controller: search,
            decoration: const InputDecoration(
              hintText: 'Search foods',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (value) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 300), () {
                setState(() => query = value);
              });
            },
          ),
          const SizedBox(height: 14),
          foods.when(
            loading: () => const AppLoading(label: 'Searching...'),
            error: (error, _) => Text(error.toString()),
            data: (items) => items.isEmpty
                ? AppEmptyState(
                    title: 'No foods found',
                    message: 'Try another search term.',
                    buttonLabel: 'Clear search',
                    onPressed: () => setState(() {
                      search.clear();
                      query = '';
                    }),
                  )
                : Column(
                    children: [
                      ...items.map(
                        (food) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FoodListCard(food: food),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
