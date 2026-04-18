import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_shadows.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import 'store_config_model.dart';

class StoreConfigurationScreen extends StatefulWidget {
  const StoreConfigurationScreen({super.key});

  @override
  State<StoreConfigurationScreen> createState() =>
      _StoreConfigurationScreenState();
}

class _StoreConfigurationScreenState extends State<StoreConfigurationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;
  
  final StoreConfigData _data = StoreConfigData();
  
  // Controllers for general info
  final _nameCtrl = TextEditingController();
  final _sloganCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _sloganCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Finalize
      Get.offNamed('/dashboard');
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
            onPressed: _prevStep,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Configuration Boutique', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.foreground)),
              Text('Étape ${_currentStep + 1} sur $_totalSteps', 
                style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text('${((_currentStep + 1) / _totalSteps * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            // Progress line
            _buildProgressBar(),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentStep = idx),
                children: [
                   _buildStep1Identity(),
                   _buildStep2Visuals(),
                   _buildStep3Location(),
                   _buildStep4Hours(),
                   _buildStep5Review(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      width: double.infinity,
      color: AppColors.border.withOpacity(0.3),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (_currentStep + 1) / _totalSteps,
        child: Container(color: AppColors.primary),
      ),
    );
  }

  // --- STEP 1: IDENTITY ---
  Widget _buildStep1Identity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Identité de votre boutique',
            icon: Icons.storefront_rounded,
          ),
          const SizedBox(height: 8),
          const Text('Comment vos clients vont-ils vous connaître ?',
            style: TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 32),
          
          _buildFieldLabel('Nom de la boutique *'),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'Ex: Togo Chic Fashion'),
            onChanged: (v) => _data.name = v,
          ),
          const SizedBox(height: 24),
          
          _buildFieldLabel('Slogan ou Accroche'),
          TextField(
            controller: _sloganCtrl,
            decoration: const InputDecoration(hintText: 'Ex: Le meilleur de Lomé'),
            onChanged: (v) => _data.slogan = v,
          ),
          const SizedBox(height: 24),
          
          _buildFieldLabel('Catégorie principale *'),
          _buildCategoryDropdown(),
          const SizedBox(height: 24),
          
          _buildFieldLabel('Description'),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Parlez de vos produits, vos valeurs...',
              alignLabelWithHint: true,
            ),
            onChanged: (v) => _data.description = v,
          ),
        ],
      ),
    );
  }

  // --- STEP 2: VISUALS ---
  Widget _buildStep2Visuals() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Image de marque',
            icon: Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 8),
          const Text('Donnez une âme visuelle à votre boutique.',
            style: TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 32),
          
          _buildFieldLabel('Photo de Couverture'),
          _buildImagePicker(
            height: 160,
            imageUrl: 'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?q=80&w=600',
            label: 'Changer la couverture',
          ),
          const SizedBox(height: 48),
          
          _buildFieldLabel('Logo ou Avatar'),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.shadowMd,
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundImage: CachedNetworkImageProvider(
                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200',
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 3: LOCATION ---
  Widget _buildStep3Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Contact et Localisation',
            icon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 8),
          const Text('Où se trouve votre point de vente ?',
            style: TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 32),
          
          _buildFieldLabel('Numéro de Téléphone Professionnel *'),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '+228 90 00 00 00',
              prefixIcon: Icon(Icons.phone_rounded, size: 20),
            ),
            onChanged: (v) => _data.phone = v,
          ),
          const SizedBox(height: 24),
          
          _buildFieldLabel('Zone Géographique *'),
          _buildZoneDropdown(),
          const SizedBox(height: 24),
          
          _buildFieldLabel('Adresse Précise'),
          TextField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              hintText: 'Ex: Rue des cocotiers, face à la pharmacie...',
              prefixIcon: Icon(Icons.map_rounded, size: 20),
            ),
            onChanged: (v) => _data.address = v,
          ),
          const SizedBox(height: 32),
          
          // Map placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: AppRadius.lgBorderRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gps_fixed_rounded, size: 40, color: AppColors.primary),
                  SizedBox(height: 12),
                  Text('Localiser sur la carte', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 4: HOURS ---
  Widget _buildStep4Hours() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SectionTitle(
          title: 'Horaires d\'Ouverture',
          icon: Icons.access_time_filled_rounded,
        ),
        const SizedBox(height: 8),
        const Text('Indiquez vos jours de travail et vos horaires, y compris les demi-journées.',
          style: TextStyle(color: AppColors.mutedForeground)),
        const SizedBox(height: 24),
        
        ...(_data.openingHours.map((h) => _buildDayHourRow(h))),
      ],
    );
  }

  // --- STEP 5: REVIEW ---
  Widget _buildStep5Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Tout semble prêt !',
            icon: Icons.verified_rounded,
          ),
          const SizedBox(height: 8),
          const Text('Vérifiez les informations de votre boutique avant de la lancer.',
            style: TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 32),
          
          _buildReviewCard(),
          const SizedBox(height: 48),
          
          Center(
            child: Column(
              children: [
                const Icon(Icons.rocket_launch_rounded, size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                Text('Félicitations ${_nameCtrl.text} !', 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const Text('Votre boutique est prête à accueillir des clients.', 
                  style: TextStyle(color: AppColors.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS HELPERS ---

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.foreground)),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppRadius.lgBorderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _data.categoryId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          items: mockCategories
              .where((c) => c.id != 'all')
              .map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        Icon(c.icon, size: 18, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(c.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _data.categoryId = v!),
        ),
      ),
    );
  }

  Widget _buildZoneDropdown() {
    final zones = ['Tokoin', 'Avépozo', 'Adidogomé', 'Bè', 'Kégué', 'Agoè'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppRadius.lgBorderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _data.zone,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          items: zones.map((z) => DropdownMenuItem(
            value: z,
            child: Text(z, style: const TextStyle(fontWeight: FontWeight.w500)),
          )).toList(),
          onChanged: (v) => setState(() => _data.zone = v!),
        ),
      ),
    );
  }

  Widget _buildImagePicker({required double height, required String imageUrl, required String label}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppRadius.lgBorderRadius,
        image: DecorationImage(
          image: CachedNetworkImageProvider(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHourRow(DayOpeningHours h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.lgBorderRadius,
          boxShadow: AppShadows.shadowSm,
          border: Border.all(color: h.isOpen ? AppColors.primary.withOpacity(0.1) : AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(h.day, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
                Switch(
                  value: h.isOpen,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => h.isOpen = v),
                ),
                Text(h.isOpen ? 'Ouvert' : 'Fermé', 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                    color: h.isOpen ? AppColors.primary : AppColors.mutedForeground
                  )),
              ],
            ),
            if (h.isOpen) ...[
              const Divider(height: 24),
              Row(
                children: [
                  _buildTimePicker(h.openingTime!, (t) => setState(() => h.openingTime = t)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('à', style: TextStyle(color: AppColors.mutedForeground)),
                  ),
                  _buildTimePicker(h.closingTime!, (t) => setState(() => h.closingTime = t)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => h.isHalfDay = !h.isHalfDay),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: h.isHalfDay ? AppColors.primary.withOpacity(0.1) : AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Demi-journée', 
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          color: h.isHalfDay ? AppColors.primary : AppColors.mutedForeground
                        )),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(TimeOfDay time, Function(TimeOfDay) onPicked) {
    return GestureDetector(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onPicked(t);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlBorderRadius,
        boxShadow: AppShadows.shadowMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 24, backgroundImage: CachedNetworkImageProvider('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200')),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_nameCtrl.text.isEmpty ? 'Nom de la boutique' : _nameCtrl.text, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(_sloganCtrl.text.isEmpty ? 'Votre slogan ici' : _sloganCtrl.text, 
                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildReviewRow(Icons.phone_rounded, _phoneCtrl.text),
          _buildReviewRow(Icons.location_on_rounded, '${_data.zone}, ${_data.address}'),
          _buildReviewRow(Icons.category_rounded, _data.categoryId.capitalizeFirst ?? ''),
        ],
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(value.isEmpty ? 'Non renseigné' : value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: _prevStep,
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _nextStep,
                child: Text(_currentStep == _totalSteps - 1 ? 'Créer ma boutique' : 'Suivant'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
