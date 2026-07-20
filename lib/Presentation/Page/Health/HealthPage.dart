import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Models/DonationCardModel.dart';
import '../../../Utils/Icons.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  late final SupabaseClient supabase;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _iapAvailable = false;
  bool _isProcessing = false;
  int? _selectedCardId;

  static const Set<String> _productIds = {'case0', 'case1', 'case2', 'case3'};

  @override
  void initState() {
    supabase = Supabase.instance.client;
    super.initState();

    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      debugPrint("IAP_ERROR: $error");
    });

    _initStore();
  }

  Future<void> _initStore() async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint("IAP_LOG: Store not available");
        setState(() {
          _iapAvailable = false;
        });
        return;
      }

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);

      if (response.error != null) {
        debugPrint("IAP_LOG: Error querying products: ${response.error!.message}");
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("IAP_LOG: Products not found: ${response.notFoundIDs}");
      }

      debugPrint("IAP_LOG: Found ${response.productDetails.length} products");

      setState(() {
        _products = response.productDetails;
        _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice)); // Trier par prix
        _iapAvailable = true;
      });
    } catch (e) {
      debugPrint("IAP_LOG: Exception in _initStore: $e");
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() => _isProcessing = true);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint("IAP_LOG: Purchase error: ${purchaseDetails.error}");
          setState(() => _isProcessing = false);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {

          await _verifyPurchaseOnServer(purchaseDetails);

          if (Platform.isAndroid) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _verifyPurchaseOnServer(PurchaseDetails purchase) async {
    try {
      final response = await supabase.functions.invoke(
        'verify-purchase',
        body: {
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'productId': purchase.productID,
          'token': purchase.verificationData.serverVerificationData,
          'transactionId': purchase.purchaseID,
          'cardId': _selectedCardId,
        },
      );

      if (response.status == 200) {
        debugPrint("IAP_LOG: Purchase verified and recorded by server!");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Merci pour votre don ! ❤️", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
          );
          setState(() {});
        }
      } else {
        debugPrint("IAP_LOG: Server verification failed with status: ${response.status}");
      }
    } catch (e) {
      debugPrint("IAP_LOG: Server verification exception: $e");
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<({List<DonationCardModel> cards, double? collecteActuelle})> _load() async {
    final rows = await supabase
        .from('donation_cards')
        .select()
        .order('sort_order', ascending: true);

    final cards = (rows as List)
        .map((e) => DonationCardModel.fromMap(e as Map<String, dynamic>))
        .toList();

    double? collecteActuelle;
    try {
      final stat = await supabase
          .from('donations_stats')
          .select('dons_collectes')
          .order('updated_at', ascending: false)
          .limit(1)
          .single();
      collecteActuelle = (stat['dons_collectes'] as num).toDouble();
    } catch (_) {/* Ignore si erreur */}

    return (cards: cards, collecteActuelle: collecteActuelle);
  }

  void _buyProduct(ProductDetails product, int cardId) {
    _selectedCardId = cardId;
    _inAppPurchase.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  void _showDonationOptions(BuildContext context, int cardId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Fond sombre premium pour la bottom sheet
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    "Choisir un montant",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  if (_isProcessing)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
                    ))
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _buyProduct(product, cardId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            side: const BorderSide(color: Colors.deepPurpleAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            product.price,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    "Merci pour votre soutien ! ❤️",
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Soutenir Amikone ❤️',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<({List<DonationCardModel> cards, double? collecteActuelle})>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}', style: const TextStyle(color: Colors.redAccent)));
          }
          final cards = snap.data!.cards;
          final collecteActuelle = snap.data!.collecteActuelle;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in cards) ...[
                  _buildCard(context, c, collecteActuelle),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, DonationCardModel c, double? collecteActuelle) {
    switch (c.kind) {
      case 'info':
        return _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconFromName(c.icon), color: Colors.deepPurpleAccent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      c.title ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              if ((c.body ?? '').isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  c.body!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ],
          ),
        );

      case 'progress':
        final objectif = c.objectif ?? 0.0;
        final actuel = c.actuel ?? collecteActuelle ?? 0.0;
        final progression = objectif > 0 ? (actuel / objectif).clamp(0, 1).toDouble() : 0.0;

        return _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconFromName(c.icon), color: Colors.deepPurpleAccent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      c.title ?? 'Objectif',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Collectés', style: TextStyle(fontSize: 14, color: Colors.white54)),
                      const SizedBox(height: 4),
                      Text(
                        '${actuel.toStringAsFixed(0)} €',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                      ),
                    ],
                  ),
                  Text(
                    'Objectif : ${objectif.toStringAsFixed(0)} €',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progression,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: Colors.deepPurpleAccent,
                  minHeight: 12,
                ),
              ),
            ],
          ),
        );

      case 'cta':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton.icon(
            onPressed: () {
              if (_iapAvailable && _products.isNotEmpty) {
                _showDonationOptions(context, c.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Le service de paiement n'est pas disponible pour le moment.", style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            icon: Icon(iconFromName(c.icon), color: Colors.white),
            label: Text(
              c.buttonLabel ?? 'Soutenir',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
              shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}