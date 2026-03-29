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
      // Appel de la Edge Function Supabase pour la vérification sécurisée
      final response = await supabase.functions.invoke(
        'verify-purchase',
        body: {
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'productId': purchase.productID,
          'token': purchase.verificationData.serverVerificationData,
          'transactionId': purchase.purchaseID,
          'cardId': _selectedCardId, // <──
        },
      );

      if (response.status == 200) {
        debugPrint("IAP_LOG: Purchase verified and recorded by server!");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Merci pour votre don ! ❤️"), backgroundColor: Colors.green),
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

  void _showDonationOptions(BuildContext context, Color primaryColor, int cardId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "Choisir un montant",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (_isProcessing)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
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
                          backgroundColor: primaryColor.withOpacity(0.1),
                          foregroundColor: primaryColor,
                          elevation: 0,
                          side: BorderSide(color: primaryColor.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          product.price,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                Text(
                  "Merci pour votre soutien ! ❤️",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Soutenir Amikone ❤️',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<({List<DonationCardModel> cards, double? collecteActuelle})>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }
          final cards = snap.data!.cards;
          final collecteActuelle = snap.data!.collecteActuelle;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in cards) ...[
                  _buildCard(context, c, collecteActuelle, primaryColor),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, DonationCardModel c, double? collecteActuelle, Color primaryColor) {
    switch (c.kind) {
      case 'info':
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconFromName(c.icon), color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        c.title ?? '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if ((c.body ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    c.body!,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ],
            ),
          ),
        );

      case 'progress':
        final objectif = c.objectif ?? 0.0;
        final actuel = c.actuel ?? collecteActuelle ?? 0.0;
        final progression = objectif > 0 ? (actuel / objectif).clamp(0, 1).toDouble() : 0.0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconFromName(c.icon), color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        c.title ?? 'Objectif',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Collectés', style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                        Text(
                          '${actuel.toStringAsFixed(0)} €',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                    Text(
                      'Objectif : ${objectif.toStringAsFixed(0)} €',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progression,
                    backgroundColor: primaryColor.withOpacity(0.15),
                    color: primaryColor,
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'cta':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton.icon(
            onPressed: () {
              if (_iapAvailable && _products.isNotEmpty) {
                _showDonationOptions(context, primaryColor, c.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Le service de paiement n'est pas disponible pour le moment.")),
                );
              }
            },
            icon: Icon(iconFromName(c.icon), color: Colors.white),
            label: Text(
              c.buttonLabel ?? 'Soutenir',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
