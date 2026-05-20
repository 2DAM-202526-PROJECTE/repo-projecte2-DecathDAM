import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ca, this message translates to:
  /// **'DecathDAM'**
  String get appTitle;

  /// No description provided for @exploreTitle.
  ///
  /// In ca, this message translates to:
  /// **'Explora'**
  String get exploreTitle;

  /// No description provided for @loginButton.
  ///
  /// In ca, this message translates to:
  /// **'Iniciar sessió'**
  String get loginButton;

  /// No description provided for @profileTitle.
  ///
  /// In ca, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @language.
  ///
  /// In ca, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @catalan.
  ///
  /// In ca, this message translates to:
  /// **'Català'**
  String get catalan;

  /// No description provided for @spanish.
  ///
  /// In ca, this message translates to:
  /// **'Castellà'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In ca, this message translates to:
  /// **'Anglès'**
  String get english;

  /// No description provided for @settings.
  ///
  /// In ca, this message translates to:
  /// **'Configuració'**
  String get settings;

  /// No description provided for @unknownError.
  ///
  /// In ca, this message translates to:
  /// **'Error desconegut'**
  String get unknownError;

  /// No description provided for @welcomeBack.
  ///
  /// In ca, this message translates to:
  /// **'Benvingut de nou!'**
  String get welcomeBack;

  /// No description provided for @email.
  ///
  /// In ca, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix el teu email'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In ca, this message translates to:
  /// **'Email no vàlid'**
  String get invalidEmail;

  /// No description provided for @password.
  ///
  /// In ca, this message translates to:
  /// **'Contrasenya'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix la contrasenya'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In ca, this message translates to:
  /// **'Has oblidat la contrasenya?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In ca, this message translates to:
  /// **'o continua amb'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In ca, this message translates to:
  /// **'Continuar amb Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In ca, this message translates to:
  /// **'No tens compte? '**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In ca, this message translates to:
  /// **'Registra\'t'**
  String get register;

  /// No description provided for @recoverPassword.
  ///
  /// In ca, this message translates to:
  /// **'Recuperar Contrasenya'**
  String get recoverPassword;

  /// No description provided for @recoverPasswordInstruction.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix el teu correu electrònic i t\'enviarem un enllaç per restablir la teva contrasenya.'**
  String get recoverPasswordInstruction;

  /// No description provided for @emailSentSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Correu enviat! Revisa la teva bústia d\'entrada.'**
  String get emailSentSuccess;

  /// No description provided for @emailSentError.
  ///
  /// In ca, this message translates to:
  /// **'Error a l\'enviar el correu'**
  String get emailSentError;

  /// No description provided for @sendLink.
  ///
  /// In ca, this message translates to:
  /// **'Enviar enllaç'**
  String get sendLink;

  /// No description provided for @changePassword.
  ///
  /// In ca, this message translates to:
  /// **'Canviar contrasenya'**
  String get changePassword;

  /// No description provided for @googleAccountPasswordChange.
  ///
  /// In ca, this message translates to:
  /// **'Aquest compte s\'identifica amb Google. Canvia la contrasenya des del teu compte de Google.'**
  String get googleAccountPasswordChange;

  /// No description provided for @home.
  ///
  /// In ca, this message translates to:
  /// **'Inici'**
  String get home;

  /// No description provided for @admin.
  ///
  /// In ca, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @favorites.
  ///
  /// In ca, this message translates to:
  /// **'Favorits'**
  String get favorites;

  /// No description provided for @cart.
  ///
  /// In ca, this message translates to:
  /// **'Cistella'**
  String get cart;

  /// No description provided for @createAccount.
  ///
  /// In ca, this message translates to:
  /// **'Crear compte'**
  String get createAccount;

  /// No description provided for @joinApp.
  ///
  /// In ca, this message translates to:
  /// **'Uneix-te a DecathDAM'**
  String get joinApp;

  /// No description provided for @fullName.
  ///
  /// In ca, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @enterName.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix el teu nom'**
  String get enterName;

  /// No description provided for @enterNewPassword.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix una contrasenya'**
  String get enterNewPassword;

  /// No description provided for @minPasswordLength.
  ///
  /// In ca, this message translates to:
  /// **'Mínim 6 caràcters'**
  String get minPasswordLength;

  /// No description provided for @confirmPassword.
  ///
  /// In ca, this message translates to:
  /// **'Confirmar contrasenya'**
  String get confirmPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In ca, this message translates to:
  /// **'Confirma la contrasenya'**
  String get enterConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ca, this message translates to:
  /// **'Les contrasenyes no coincideixen'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ca, this message translates to:
  /// **'Ja tens compte? '**
  String get alreadyHaveAccount;

  /// No description provided for @userNoName.
  ///
  /// In ca, this message translates to:
  /// **'Usuari sense nom'**
  String get userNoName;

  /// No description provided for @role.
  ///
  /// In ca, this message translates to:
  /// **'Rol: '**
  String get role;

  /// No description provided for @personalInfo.
  ///
  /// In ca, this message translates to:
  /// **'La meva informació personal'**
  String get personalInfo;

  /// No description provided for @theme.
  ///
  /// In ca, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In ca, this message translates to:
  /// **'Sistema'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In ca, this message translates to:
  /// **'Clar'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In ca, this message translates to:
  /// **'Fosc'**
  String get darkTheme;

  /// No description provided for @notifications.
  ///
  /// In ca, this message translates to:
  /// **'Notificacions'**
  String get notifications;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In ca, this message translates to:
  /// **'Notificacions pròximament'**
  String get notificationsComingSoon;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In ca, this message translates to:
  /// **'Privacitat i Seguretat'**
  String get privacyAndSecurity;

  /// No description provided for @privacyComingSoon.
  ///
  /// In ca, this message translates to:
  /// **'Privacitat pròximament'**
  String get privacyComingSoon;

  /// No description provided for @logout.
  ///
  /// In ca, this message translates to:
  /// **'Tancar Sessió'**
  String get logout;

  /// No description provided for @noImagesFound.
  ///
  /// In ca, this message translates to:
  /// **'No s\'han trobat imatges.'**
  String get noImagesFound;

  /// No description provided for @homeSubtitle.
  ///
  /// In ca, this message translates to:
  /// **'El nostre propòsit és que assoleixis els teus objectius'**
  String get homeSubtitle;

  /// No description provided for @featuredProducts.
  ///
  /// In ca, this message translates to:
  /// **'Productes destacats'**
  String get featuredProducts;

  /// No description provided for @noProductsAvailable.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha productes disponibles.'**
  String get noProductsAvailable;

  /// No description provided for @noProductImages.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha imatges de productes.'**
  String get noProductImages;

  /// No description provided for @searchProducts.
  ///
  /// In ca, this message translates to:
  /// **'Cerca productes...'**
  String get searchProducts;

  /// No description provided for @noResultsModifyFilters.
  ///
  /// In ca, this message translates to:
  /// **'No s\'han trobat resultats\nmodifica els filtres'**
  String get noResultsModifyFilters;

  /// No description provided for @advancedFilters.
  ///
  /// In ca, this message translates to:
  /// **'Filtres Avanzats'**
  String get advancedFilters;

  /// No description provided for @clearAll.
  ///
  /// In ca, this message translates to:
  /// **'Netejar Tot'**
  String get clearAll;

  /// No description provided for @categories.
  ///
  /// In ca, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @sorting.
  ///
  /// In ca, this message translates to:
  /// **'Ordenació'**
  String get sorting;

  /// No description provided for @defaultSort.
  ///
  /// In ca, this message translates to:
  /// **'Per defecte'**
  String get defaultSort;

  /// No description provided for @lowestPrice.
  ///
  /// In ca, this message translates to:
  /// **'Preu més baix'**
  String get lowestPrice;

  /// No description provided for @highestPrice.
  ///
  /// In ca, this message translates to:
  /// **'Preu més alt'**
  String get highestPrice;

  /// No description provided for @priceRange.
  ///
  /// In ca, this message translates to:
  /// **'Rang de Preu'**
  String get priceRange;

  /// No description provided for @applyFilters.
  ///
  /// In ca, this message translates to:
  /// **'Aplicar Filtres'**
  String get applyFilters;

  /// No description provided for @description.
  ///
  /// In ca, this message translates to:
  /// **'Descripció'**
  String get description;

  /// No description provided for @addedToCart.
  ///
  /// In ca, this message translates to:
  /// **'afegit a la cistella'**
  String get addedToCart;

  /// No description provided for @undo.
  ///
  /// In ca, this message translates to:
  /// **'DESFER'**
  String get undo;

  /// No description provided for @addToCartButton.
  ///
  /// In ca, this message translates to:
  /// **'Afegir a la cistella'**
  String get addToCartButton;

  /// No description provided for @emptyCartTitle.
  ///
  /// In ca, this message translates to:
  /// **'La teva cistella està buida'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartMessage.
  ///
  /// In ca, this message translates to:
  /// **'Explora els nostres productes i afegeix-ne algun!'**
  String get emptyCartMessage;

  /// No description provided for @goToStore.
  ///
  /// In ca, this message translates to:
  /// **'Anar a la botiga'**
  String get goToStore;

  /// No description provided for @perUnit.
  ///
  /// In ca, this message translates to:
  /// **'/ unitat'**
  String get perUnit;

  /// No description provided for @total.
  ///
  /// In ca, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @payNow.
  ///
  /// In ca, this message translates to:
  /// **'Pagar ara'**
  String get payNow;

  /// No description provided for @yourFavorites.
  ///
  /// In ca, this message translates to:
  /// **'Els teus favorits'**
  String get yourFavorites;

  /// No description provided for @noSavedProducts.
  ///
  /// In ca, this message translates to:
  /// **'Encara no tens productes guardats'**
  String get noSavedProducts;

  /// No description provided for @paymentSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Pagament realitzat amb èxit! Gràcies per la teva compra.'**
  String get paymentSuccess;

  /// No description provided for @paymentError.
  ///
  /// In ca, this message translates to:
  /// **'Error en el pagament o cancel·lat'**
  String get paymentError;

  /// No description provided for @fillAllFields.
  ///
  /// In ca, this message translates to:
  /// **'Si us plau, omple totes les dades necessàries.'**
  String get fillAllFields;

  /// No description provided for @errorSavingAddress.
  ///
  /// In ca, this message translates to:
  /// **'Error al guardar l\'adreça'**
  String get errorSavingAddress;

  /// No description provided for @shippingDataTitle.
  ///
  /// In ca, this message translates to:
  /// **'Dades d\'enviament'**
  String get shippingDataTitle;

  /// No description provided for @contactInfo.
  ///
  /// In ca, this message translates to:
  /// **'Informació de contacte'**
  String get contactInfo;

  /// No description provided for @phone.
  ///
  /// In ca, this message translates to:
  /// **'Telèfon'**
  String get phone;

  /// No description provided for @shippingAddress.
  ///
  /// In ca, this message translates to:
  /// **'Adreça d\'enviament'**
  String get shippingAddress;

  /// No description provided for @country.
  ///
  /// In ca, this message translates to:
  /// **'País'**
  String get country;

  /// No description provided for @address.
  ///
  /// In ca, this message translates to:
  /// **'Carrer, pis, porta'**
  String get address;

  /// No description provided for @postalCode.
  ///
  /// In ca, this message translates to:
  /// **'Codi Postal'**
  String get postalCode;

  /// No description provided for @city.
  ///
  /// In ca, this message translates to:
  /// **'Ciutat'**
  String get city;

  /// No description provided for @billingDataTitle.
  ///
  /// In ca, this message translates to:
  /// **'Dades de facturació'**
  String get billingDataTitle;

  /// No description provided for @billingSameAsShipping.
  ///
  /// In ca, this message translates to:
  /// **'L\'adreça de facturació és la mateixa que la d\'enviament'**
  String get billingSameAsShipping;

  /// No description provided for @billingFullName.
  ///
  /// In ca, this message translates to:
  /// **'Nom complet / Entitat de facturació'**
  String get billingFullName;

  /// No description provided for @billingNif.
  ///
  /// In ca, this message translates to:
  /// **'NIF / CIF'**
  String get billingNif;

  /// No description provided for @billingCountry.
  ///
  /// In ca, this message translates to:
  /// **'País de facturació'**
  String get billingCountry;

  /// No description provided for @billingAddress.
  ///
  /// In ca, this message translates to:
  /// **'Adreça de facturació'**
  String get billingAddress;

  /// No description provided for @billingPostalCode.
  ///
  /// In ca, this message translates to:
  /// **'Codi Postal de facturació'**
  String get billingPostalCode;

  /// No description provided for @billingCity.
  ///
  /// In ca, this message translates to:
  /// **'Ciutat de facturació'**
  String get billingCity;

  /// No description provided for @viewOrderDetails.
  ///
  /// In ca, this message translates to:
  /// **'Veure dades d\'enviament i facturació'**
  String get viewOrderDetails;

  /// No description provided for @hideOrderDetails.
  ///
  /// In ca, this message translates to:
  /// **'Amagar dades de l\'ordre'**
  String get hideOrderDetails;

  /// No description provided for @saveDataForFuture.
  ///
  /// In ca, this message translates to:
  /// **'Guardar dades per a futures compres'**
  String get saveDataForFuture;

  /// No description provided for @pay.
  ///
  /// In ca, this message translates to:
  /// **'Pagar'**
  String get pay;

  /// No description provided for @defaultCountry.
  ///
  /// In ca, this message translates to:
  /// **'Espanya'**
  String get defaultCountry;

  /// No description provided for @languageComingSoon.
  ///
  /// In ca, this message translates to:
  /// **'Funció d\'idioma pròximament'**
  String get languageComingSoon;

  /// No description provided for @manageAlerts.
  ///
  /// In ca, this message translates to:
  /// **'Gestiona les alertes de l\'app'**
  String get manageAlerts;

  /// No description provided for @logoutConfirmation.
  ///
  /// In ca, this message translates to:
  /// **'Estàs segur que vols tancar la sessió? Hauràs d\'iniciar sessió de nou per accedir.'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In ca, this message translates to:
  /// **'Cancel·lar'**
  String get cancel;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In ca, this message translates to:
  /// **'El nom no pot estar buit'**
  String get nameCannotBeEmpty;

  /// No description provided for @infoUpdated.
  ///
  /// In ca, this message translates to:
  /// **'Informació actualitzada correctament'**
  String get infoUpdated;

  /// No description provided for @errorUpdating.
  ///
  /// In ca, this message translates to:
  /// **'Error al actualitzar'**
  String get errorUpdating;

  /// No description provided for @myInformation.
  ///
  /// In ca, this message translates to:
  /// **'La meva informació'**
  String get myInformation;

  /// No description provided for @personalData.
  ///
  /// In ca, this message translates to:
  /// **'Dades Personals'**
  String get personalData;

  /// No description provided for @emailCannotBeModified.
  ///
  /// In ca, this message translates to:
  /// **'El correu electrònic no es pot modificar directament per seguretat.'**
  String get emailCannotBeModified;

  /// No description provided for @dni.
  ///
  /// In ca, this message translates to:
  /// **'DNI'**
  String get dni;

  /// No description provided for @birthDate.
  ///
  /// In ca, this message translates to:
  /// **'Data de Naixement'**
  String get birthDate;

  /// No description provided for @dateFormat.
  ///
  /// In ca, this message translates to:
  /// **'DD/MM/AAAA'**
  String get dateFormat;

  /// No description provided for @gender.
  ///
  /// In ca, this message translates to:
  /// **'Gènere'**
  String get gender;

  /// No description provided for @saveChanges.
  ///
  /// In ca, this message translates to:
  /// **'Desar Canvis'**
  String get saveChanges;

  /// No description provided for @appearance.
  ///
  /// In ca, this message translates to:
  /// **'Aparença'**
  String get appearance;

  /// No description provided for @changeTheme.
  ///
  /// In ca, this message translates to:
  /// **'Canvia entre mode clar, fosc o sistema'**
  String get changeTheme;

  /// No description provided for @adminPanel.
  ///
  /// In ca, this message translates to:
  /// **'Panell d\'Administració'**
  String get adminPanel;

  /// No description provided for @manageProductsUsers.
  ///
  /// In ca, this message translates to:
  /// **'Gestiona productes i usuaris'**
  String get manageProductsUsers;

  /// No description provided for @quickManagement.
  ///
  /// In ca, this message translates to:
  /// **'Gestió ràpida'**
  String get quickManagement;

  /// No description provided for @createProducts.
  ///
  /// In ca, this message translates to:
  /// **'Crear Productes'**
  String get createProducts;

  /// No description provided for @addProductsCatalog.
  ///
  /// In ca, this message translates to:
  /// **'Afegeix nous productes al catàleg'**
  String get addProductsCatalog;

  /// No description provided for @manageProducts.
  ///
  /// In ca, this message translates to:
  /// **'Administrar Productes'**
  String get manageProducts;

  /// No description provided for @editDeleteProducts.
  ///
  /// In ca, this message translates to:
  /// **'Edita o elimina productes existents'**
  String get editDeleteProducts;

  /// No description provided for @chooseFeatured.
  ///
  /// In ca, this message translates to:
  /// **'Tria quins productes es veuen a l\'inici'**
  String get chooseFeatured;

  /// No description provided for @createUser.
  ///
  /// In ca, this message translates to:
  /// **'Crear Usuari'**
  String get createUser;

  /// No description provided for @addNewUserFull.
  ///
  /// In ca, this message translates to:
  /// **'Afegeix un nou usuari amb dades completes'**
  String get addNewUserFull;

  /// No description provided for @manageUsers.
  ///
  /// In ca, this message translates to:
  /// **'Administrar Usuaris'**
  String get manageUsers;

  /// No description provided for @manageRolesPerms.
  ///
  /// In ca, this message translates to:
  /// **'Gestiona rols i permisos dels usuaris'**
  String get manageRolesPerms;

  /// No description provided for @generateTestData.
  ///
  /// In ca, this message translates to:
  /// **'Generar Dades de Prova'**
  String get generateTestData;

  /// No description provided for @createRealisticProducts.
  ///
  /// In ca, this message translates to:
  /// **'Crea productes realistes automàticament'**
  String get createRealisticProducts;

  /// No description provided for @fixImages.
  ///
  /// In ca, this message translates to:
  /// **'Reparar Imatges'**
  String get fixImages;

  /// No description provided for @fixBrokenImages.
  ///
  /// In ca, this message translates to:
  /// **'Arregla les imatges que no es veuen'**
  String get fixBrokenImages;

  /// No description provided for @products.
  ///
  /// In ca, this message translates to:
  /// **'Productes'**
  String get products;

  /// No description provided for @users.
  ///
  /// In ca, this message translates to:
  /// **'Usuaris'**
  String get users;

  /// No description provided for @seedConfirmationText.
  ///
  /// In ca, this message translates to:
  /// **'Aquesta acció afegirà 10 productes realistes al catàleg. Vols continuar?'**
  String get seedConfirmationText;

  /// No description provided for @generatingProducts.
  ///
  /// In ca, this message translates to:
  /// **'Generant productes...'**
  String get generatingProducts;

  /// No description provided for @productsGenerated.
  ///
  /// In ca, this message translates to:
  /// **'Productes generats correctament!'**
  String get productsGenerated;

  /// No description provided for @errorGeneratingProducts.
  ///
  /// In ca, this message translates to:
  /// **'Error al generar productes: '**
  String get errorGeneratingProducts;

  /// No description provided for @generate.
  ///
  /// In ca, this message translates to:
  /// **'Generar'**
  String get generate;

  /// No description provided for @fixImagesConfirmation.
  ///
  /// In ca, this message translates to:
  /// **'Aquesta acció buscarà productes amb imatges trencades (de la càrrega anterior) i les intentarà arreglar. Vols continuar?'**
  String get fixImagesConfirmation;

  /// No description provided for @fixingImages.
  ///
  /// In ca, this message translates to:
  /// **'Reparant imatges...'**
  String get fixingImages;

  /// No description provided for @imagesFixed.
  ///
  /// In ca, this message translates to:
  /// **'Imatges reparades correctament!'**
  String get imagesFixed;

  /// No description provided for @errorFixingImages.
  ///
  /// In ca, this message translates to:
  /// **'Error al reparar imatges: '**
  String get errorFixingImages;

  /// No description provided for @fix.
  ///
  /// In ca, this message translates to:
  /// **'Reparar'**
  String get fix;

  /// No description provided for @productCreatedSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Producte creat correctament'**
  String get productCreatedSuccess;

  /// No description provided for @errorCreatingProduct.
  ///
  /// In ca, this message translates to:
  /// **'Error en crear el producte: '**
  String get errorCreatingProduct;

  /// No description provided for @newProduct.
  ///
  /// In ca, this message translates to:
  /// **'Nou Producte'**
  String get newProduct;

  /// No description provided for @productDetails.
  ///
  /// In ca, this message translates to:
  /// **'Detalls del Producte'**
  String get productDetails;

  /// No description provided for @fillInfoToCreateProduct.
  ///
  /// In ca, this message translates to:
  /// **'Omple la informació per crear una nova fitxa al catàleg.'**
  String get fillInfoToCreateProduct;

  /// No description provided for @productName.
  ///
  /// In ca, this message translates to:
  /// **'Nom del Producte'**
  String get productName;

  /// No description provided for @productNameExample.
  ///
  /// In ca, this message translates to:
  /// **'Ex: Bambes de Running Kalenji'**
  String get productNameExample;

  /// No description provided for @enterProductName.
  ///
  /// In ca, this message translates to:
  /// **'Si us plau, introdueix un nom'**
  String get enterProductName;

  /// No description provided for @descriptionHint.
  ///
  /// In ca, this message translates to:
  /// **'Descriu les característiques tècniques...'**
  String get descriptionHint;

  /// No description provided for @enterDescription.
  ///
  /// In ca, this message translates to:
  /// **'Si us plau, introdueix una descripció'**
  String get enterDescription;

  /// No description provided for @priceLabel.
  ///
  /// In ca, this message translates to:
  /// **'Preu (€)'**
  String get priceLabel;

  /// No description provided for @priceExample.
  ///
  /// In ca, this message translates to:
  /// **'0.00'**
  String get priceExample;

  /// No description provided for @enterPrice.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix un preu'**
  String get enterPrice;

  /// No description provided for @invalidPrice.
  ///
  /// In ca, this message translates to:
  /// **'Preu no vàlid'**
  String get invalidPrice;

  /// No description provided for @categoryTitle.
  ///
  /// In ca, this message translates to:
  /// **'Categoria'**
  String get categoryTitle;

  /// No description provided for @chooseOne.
  ///
  /// In ca, this message translates to:
  /// **'Tria una'**
  String get chooseOne;

  /// No description provided for @chooseCategory.
  ///
  /// In ca, this message translates to:
  /// **'Tria una categoria'**
  String get chooseCategory;

  /// No description provided for @imageUrl.
  ///
  /// In ca, this message translates to:
  /// **'URL de la Imatge'**
  String get imageUrl;

  /// No description provided for @imageUrlHint.
  ///
  /// In ca, this message translates to:
  /// **'https://exemple.com/imatge.jpg'**
  String get imageUrlHint;

  /// No description provided for @enterUrl.
  ///
  /// In ca, this message translates to:
  /// **'Si us plau, introdueix una URL'**
  String get enterUrl;

  /// No description provided for @createProductButton.
  ///
  /// In ca, this message translates to:
  /// **'Crear Producte'**
  String get createProductButton;

  /// No description provided for @noProducts.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha productes'**
  String get noProducts;

  /// No description provided for @edit.
  ///
  /// In ca, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @deleteProductConfirmation.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar producte?'**
  String get deleteProductConfirmation;

  /// No description provided for @deleteProductText.
  ///
  /// In ca, this message translates to:
  /// **'Estàs segur que vols eliminar \"{productName}\"? Aquesta acció no es pot desfer.'**
  String deleteProductText(String productName);

  /// No description provided for @productDeleted.
  ///
  /// In ca, this message translates to:
  /// **'Producte eliminat: '**
  String get productDeleted;

  /// No description provided for @errorDeleting.
  ///
  /// In ca, this message translates to:
  /// **'Error en eliminar: '**
  String get errorDeleting;

  /// No description provided for @productUpdatedSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Producte actualitzat correctament'**
  String get productUpdatedSuccess;

  /// No description provided for @errorUpdatingProduct.
  ///
  /// In ca, this message translates to:
  /// **'Error en actualitzar: '**
  String get errorUpdatingProduct;

  /// No description provided for @editProduct.
  ///
  /// In ca, this message translates to:
  /// **'Editar Producte'**
  String get editProduct;

  /// No description provided for @modifyProduct.
  ///
  /// In ca, this message translates to:
  /// **'Modificar Producte'**
  String get modifyProduct;

  /// No description provided for @updateProductInfo.
  ///
  /// In ca, this message translates to:
  /// **'Actualitza la informació del producte.'**
  String get updateProductInfo;

  /// No description provided for @searchUsers.
  ///
  /// In ca, this message translates to:
  /// **'Cercar per nom o email...'**
  String get searchUsers;

  /// No description provided for @noUsers.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha usuaris'**
  String get noUsers;

  /// No description provided for @addFirstUser.
  ///
  /// In ca, this message translates to:
  /// **'Afegeix el primer usuari amb el botó +'**
  String get addFirstUser;

  /// No description provided for @noResultsFor.
  ///
  /// In ca, this message translates to:
  /// **'Cap resultat per \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @userCreatedSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Usuari creat correctament'**
  String get userCreatedSuccess;

  /// No description provided for @errorCreatingUser.
  ///
  /// In ca, this message translates to:
  /// **'Error al crear usuari: '**
  String get errorCreatingUser;

  /// No description provided for @createNewUser.
  ///
  /// In ca, this message translates to:
  /// **'Crear Nou Usuari'**
  String get createNewUser;

  /// No description provided for @basicInfo.
  ///
  /// In ca, this message translates to:
  /// **'Informació Bàsica'**
  String get basicInfo;

  /// No description provided for @requiredField.
  ///
  /// In ca, this message translates to:
  /// **'Camp obligatori'**
  String get requiredField;

  /// No description provided for @deliveryAddress.
  ///
  /// In ca, this message translates to:
  /// **'Adreça de Lliurament'**
  String get deliveryAddress;

  /// No description provided for @addressLabel.
  ///
  /// In ca, this message translates to:
  /// **'Adreça (Carrer, núm, porta)'**
  String get addressLabel;

  /// No description provided for @createUserButton.
  ///
  /// In ca, this message translates to:
  /// **'Crear Usuari'**
  String get createUserButton;

  /// No description provided for @userRoleLabel.
  ///
  /// In ca, this message translates to:
  /// **'Rol d\'usuari'**
  String get userRoleLabel;

  /// No description provided for @clientRole.
  ///
  /// In ca, this message translates to:
  /// **'Client'**
  String get clientRole;

  /// No description provided for @adminRole.
  ///
  /// In ca, this message translates to:
  /// **'Administrador'**
  String get adminRole;

  /// No description provided for @selectFeaturedProductsText.
  ///
  /// In ca, this message translates to:
  /// **'Selecciona fins a 4 productes per mostrar a la pàgina principal. Actualment seleccionats: {count}/4'**
  String selectFeaturedProductsText(int count);

  /// No description provided for @maxFeaturedProductsError.
  ///
  /// In ca, this message translates to:
  /// **'Només pots tenir un màxim de 4 productes destacats.'**
  String get maxFeaturedProductsError;

  /// No description provided for @inactive.
  ///
  /// In ca, this message translates to:
  /// **'Inactiu'**
  String get inactive;

  /// No description provided for @makeClient.
  ///
  /// In ca, this message translates to:
  /// **'Fer Client'**
  String get makeClient;

  /// No description provided for @makeAdmin.
  ///
  /// In ca, this message translates to:
  /// **'Fer Admin'**
  String get makeAdmin;

  /// No description provided for @deactivate.
  ///
  /// In ca, this message translates to:
  /// **'Desactivar'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In ca, this message translates to:
  /// **'Activar'**
  String get activate;

  /// No description provided for @userNowIsRole.
  ///
  /// In ca, this message translates to:
  /// **'{user} ara és {role}'**
  String userNowIsRole(String user, String role);

  /// No description provided for @userActivated.
  ///
  /// In ca, this message translates to:
  /// **'{user} activat'**
  String userActivated(String user);

  /// No description provided for @userDeactivated.
  ///
  /// In ca, this message translates to:
  /// **'{user} desactivat'**
  String userDeactivated(String user);

  /// No description provided for @deleteUserConfirmation.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar usuari?'**
  String get deleteUserConfirmation;

  /// No description provided for @deleteUserText.
  ///
  /// In ca, this message translates to:
  /// **'Estàs segur que vols eliminar \"{user}\"? Aquesta acció no es pot desfer.'**
  String deleteUserText(String user);

  /// No description provided for @userDeleted.
  ///
  /// In ca, this message translates to:
  /// **'Usuari eliminat: {user}'**
  String userDeleted(String user);

  /// No description provided for @purchaseHistory.
  ///
  /// In ca, this message translates to:
  /// **'Historial de compres'**
  String get purchaseHistory;

  /// No description provided for @noPurchases.
  ///
  /// In ca, this message translates to:
  /// **'No tens cap compra encara'**
  String get noPurchases;

  /// No description provided for @orderNumber.
  ///
  /// In ca, this message translates to:
  /// **'Comanda #{id}'**
  String orderNumber(Object id);

  /// No description provided for @manageCategories.
  ///
  /// In ca, this message translates to:
  /// **'Gestionar Categories'**
  String get manageCategories;

  /// No description provided for @manageCategoriesSubtitle.
  ///
  /// In ca, this message translates to:
  /// **'Crea, edita i ordena les categories'**
  String get manageCategoriesSubtitle;

  /// No description provided for @newCategory.
  ///
  /// In ca, this message translates to:
  /// **'Nova Categoria'**
  String get newCategory;

  /// No description provided for @editCategory.
  ///
  /// In ca, this message translates to:
  /// **'Editar Categoria'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In ca, this message translates to:
  /// **'Nom de la categoria'**
  String get categoryName;

  /// No description provided for @enterCategoryName.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix un nom per a la categoria'**
  String get enterCategoryName;

  /// No description provided for @noCategories.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha categories'**
  String get noCategories;

  /// No description provided for @createFirstCategory.
  ///
  /// In ca, this message translates to:
  /// **'Crea la primera categoria amb el botó +'**
  String get createFirstCategory;

  /// No description provided for @categoryCreated.
  ///
  /// In ca, this message translates to:
  /// **'Categoria creada correctament'**
  String get categoryCreated;

  /// No description provided for @categoryUpdated.
  ///
  /// In ca, this message translates to:
  /// **'Categoria actualitzada correctament'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In ca, this message translates to:
  /// **'Categoria eliminada correctament'**
  String get categoryDeleted;

  /// No description provided for @deleteCategoryConfirmation.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar categoria?'**
  String get deleteCategoryConfirmation;

  /// No description provided for @deleteCategoryText.
  ///
  /// In ca, this message translates to:
  /// **'Estàs segur que vols eliminar \"{categoryName}\"? Aquesta acció no es pot desfer.'**
  String deleteCategoryText(String categoryName);

  /// No description provided for @categoryHasProducts.
  ///
  /// In ca, this message translates to:
  /// **'Aquesta categoria té {count} producte(s) associat(s). Es quedaran sense categoria.'**
  String categoryHasProducts(int count);

  /// No description provided for @create.
  ///
  /// In ca, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @noCategory.
  ///
  /// In ca, this message translates to:
  /// **'Sense categoria'**
  String get noCategory;

  /// No description provided for @migrateCategories.
  ///
  /// In ca, this message translates to:
  /// **'Migrar Categories'**
  String get migrateCategories;

  /// No description provided for @migrateCategoriesSubtitle.
  ///
  /// In ca, this message translates to:
  /// **'Converteix les categories antigues al nou sistema'**
  String get migrateCategoriesSubtitle;

  /// No description provided for @migrateCategoriesConfirmation.
  ///
  /// In ca, this message translates to:
  /// **'Migrar categories?'**
  String get migrateCategoriesConfirmation;

  /// No description provided for @migrateCategoriesText.
  ///
  /// In ca, this message translates to:
  /// **'Aquesta acció convertirà el camp antic \'categoria\' de cada producte a una referència a la col·lecció de categories. Hi ha {count} producte(s) pendents de migrar.'**
  String migrateCategoriesText(int count);

  /// No description provided for @migratingCategories.
  ///
  /// In ca, this message translates to:
  /// **'Migrant categories...'**
  String get migratingCategories;

  /// No description provided for @migrationSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Migració completada: {updated} producte(s) actualitzat(s), {created} categoria(es) creada(es)'**
  String migrationSuccess(int updated, int created);

  /// No description provided for @migrationNotNeeded.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha productes pendents de migrar!'**
  String get migrationNotNeeded;

  /// No description provided for @migrate.
  ///
  /// In ca, this message translates to:
  /// **'Migrar'**
  String get migrate;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
