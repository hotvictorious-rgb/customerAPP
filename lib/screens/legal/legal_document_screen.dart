import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/legal_document_model.dart';
import '../../providers/app_config_provider.dart';
import '../../widgets/brand_app_bar.dart';

class LegalDocumentScreen extends StatefulWidget {
  final String slug;
  final String? initialTitle;

  const LegalDocumentScreen({
    super.key,
    required this.slug,
    this.initialTitle,
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  bool _isLoading = true;
  String? _error;
  LegalDocumentModel? _document;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocument();
    });
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prov = context.read<AppConfigProvider>();
    final doc = await prov.fetchLegalDocument(widget.slug);

    if (!mounted) return;

    if (doc != null) {
      setState(() {
        _document = doc;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Unable to load official policy. Please check network connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _document?.title ?? widget.initialTitle ?? 'Official Policy';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: BrandAppBar(
        title: title,
        showBack: true,
        showCart: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, size: 56, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadDocument,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primaryPurple,
                  onRefresh: _loadDocument,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Governance & Integrity Header Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: AppColors.royalPurpleGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.purpleShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondaryGold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.verified_user, color: AppColors.textPrimary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _document!.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Category: ${_document!.category}',
                                          style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  if (_document!.version != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Version: v${_document!.version}',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  if (_document!.effectiveDateFormatted != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryGold.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Effective: ${_document!.effectiveDateFormatted}',
                                        style: const TextStyle(color: AppColors.secondaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Executive Summary Box
                        if (_document!.summary != null && _document!.summary!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGoldLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.secondaryGold),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline, color: AppColors.primaryPurple, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _document!.summary!,
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Rendered Document Content
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: _buildFormattedContent(_document!.contentMarkdown ?? ''),
                        ),

                        const SizedBox(height: 20),

                        // Platform Governance Trust Seal
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield, color: AppColors.primaryPurple, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cryptographically Enforced Policy',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Victorious MARKET operates strictly under bank-grade escrow governance, 24-hour return rights, and Nigerian digital commerce consumer protections.',
                                      style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary, height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFormattedContent(String markdown) {
    if (markdown.trim().isEmpty) {
      return const Text('Policy content is currently being finalized.');
    }

    final lines = markdown.split('\n');
    final List<Widget> widgets = [];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (trimmed.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            trimmed.replaceFirst('# ', ''),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
        ));
      } else if (trimmed.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            trimmed.replaceFirst('## ', ''),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryDarkPurple),
          ),
        ));
      } else if (trimmed.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            trimmed.replaceFirst('### ', ''),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ));
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        final text = trimmed.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 14)),
              Expanded(
                child: Text(
                  text.replaceAll('**', ''),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.4),
                ),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            trimmed.replaceAll('**', ''),
            style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.45),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
