"use client";

import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

type Tab = "terms" | "privacy";
type Language = "ar" | "fr";

const whatsappNumber = "213542916461";

function whatsappUrl(language: Language) {
  const message =
    language === "ar"
      ? "السلام عليكم، لدي استفسار حول شروط الاستخدام أو سياسة الخصوصية لمنصة صحّتك تيك."
      : "Bonjour, j'ai une question concernant les conditions d'utilisation ou la politique de confidentialité de DZ HEALTH TECH.";

  return `https://wa.me/${whatsappNumber}?text=${encodeURIComponent(message)}`;
}

export default function TermsPage() {
  const [activeTab, setActiveTab] = useState<Tab>("terms");
  const [language, setLanguage] = useState<Language>("ar");

  const isArabic = language === "ar";
  const contactUrl = whatsappUrl(language);

  const content = isArabic
    ? {
        back: "العودة إلى الرئيسية",
        login: "تسجيل الدخول",
        language: "FR",
        title: "الشروط والخصوصية",
        subtitle:
          "نوضح هنا القواعد التي تنظّم استخدام منصة صحّتك تيك وكيفية التعامل مع البيانات داخل المنصة.",
        updated: "آخر تحديث: 24 أغسطس 2026",
        terms: "الشروط والأحكام",
        privacy: "سياسة الخصوصية",
        contact: "تواصل معنا عبر واتساب",
        noticeTitle: "تنبيه مهم",
        noticeText:
          "صحّتك تيك منصة رقمية مساعدة لتنظيم المعلومات داخل المؤسسات الصحية. لا تقدم تشخيصًا طبيًا، ولا تحل محل الطبيب أو الطاقم الصحي أو إجراءات الطوارئ الرسمية.",
        termsIntro:
          "باستخدام المنصة أو إنشاء حساب فيها أو طلب انضمام مؤسسة صحية، فإنك توافق على هذه الشروط والأحكام. إذا كنت تمثل مؤسسة، فأنت تؤكد أن لديك الصلاحية اللازمة للتصرف باسمها.",
        termsSections: [
          {
            title: "1. نطاق الخدمة",
            paragraphs: [
              "توفر صحّتك تيك أدوات رقمية للمؤسسات الصحية من أجل تنظيم بيانات المرضى، إدارة المستخدمين والصلاحيات، متابعة الملفات الطبية، واستعمال رمز QR للوصول المصرح به إلى المعلومات الضرورية.",
              "قد تتضمن المنصة وظائف مرتبطة بالطوارئ، مثل عرض معلومات المريض أو تسجيل الوصول. هذه الوظائف أدوات مساعدة ولا تمثل بديلاً عن أرقام الطوارئ، أو بروتوكولات المؤسسة الصحية، أو التقييم الطبي المهني.",
            ],
          },
          {
            title: "2. الحسابات وصلاحيات المستخدمين",
            paragraphs: [
              "تُنشأ الحسابات وتُمنح الصلاحيات حسب الدور داخل المؤسسة، مثل مدير المؤسسة، الطبيب، أو الموظف المخوّل.",
              "يتحمل مدير المؤسسة مسؤولية صحة بيانات المستخدمين الذين يضيفهم، وتحديد أدوارهم، وتعطيل وصول أي مستخدم لم يعد مخولاً بالعمل داخل المؤسسة.",
              "يجب الحفاظ على سرية بيانات تسجيل الدخول وعدم مشاركتها. يجب الإبلاغ فورًا عند الاشتباه في استعمال غير مصرح به للحساب.",
            ],
          },
          {
            title: "3. التزامات المؤسسة الصحية",
            paragraphs: [
              "تؤكد المؤسسة الصحية أنها تملك أساسًا قانونيًا ومهنيًا مناسبًا لإدخال بيانات المرضى ومعالجتها داخل المنصة.",
              "تلتزم المؤسسة بالحصول على الموافقات اللازمة، واحترام سرية المهنة، وتطبيق القوانين واللوائح الصحية وحماية البيانات المعمول بها في الجزائر.",
              "لا يجوز استعمال المنصة لرفع أو تداول بيانات غير مشروعة أو مضللة، أو لإتاحة الوصول إلى معلومات المرضى لأشخاص غير مخولين.",
            ],
          },
          {
            title: "4. بيانات المرضى والملفات الطبية",
            paragraphs: [
              "تستخدم المؤسسة المنصة لإدارة البيانات التي تدخلها أو ترفعها وفق صلاحيات مستخدميها. تبقى المؤسسة والجهات المخولة لديها مسؤولة عن دقة البيانات وحداثتها ومشروعية استخدامها.",
              "تُقيّد إدارة الملفات الطبية حسب الصلاحيات. على وجه الخصوص، يكون رفع الملفات أو حذفها أو تنزيلها مخصصًا للأدوار المخولة، مثل الطبيب، وفق إعدادات المنصة.",
              "لا يجوز استخدام المنصة كبديل وحيد عن أنظمة الأرشفة أو النسخ الاحتياطي التي تلتزم بها المؤسسة وفق قوانينها وإجراءاتها الداخلية.",
            ],
          },
          {
            title: "5. استعمال رمز QR",
            paragraphs: [
              "قد تتيح المنصة رمز QR مرتبطًا بالمريض للوصول السريع إلى بيانات محددة عند الحاجة.",
              "لا يجوز مسح رمز QR أو محاولة الوصول إلى بيانات المريض إلا من قبل موظف مخول وحساب مرتبط بمؤسسة صحية نشطة داخل المنصة.",
              "يمكن تسجيل عمليات مسح QR، بما في ذلك المؤسسة والموظف والتوقيت، لأغراض المراجعة الداخلية والأمان وتتبع الوصول.",
            ],
          },
          {
            title: "6. حالات الطوارئ",
            paragraphs: [
              "توفر المنصة أدوات رقمية مساعدة تتعلق بحالات الطوارئ، مثل عرض معلومات محددة أو تسجيل وصول المريض إلى مؤسسة صحية.",
              "المستخدم والمؤسسة مسؤولان عن اتباع الإجراءات الطبية والقانونية المعتمدة. يجب الاتصال بخدمات الطوارئ الرسمية أو التوجه إلى أقرب جهة صحية عند وجود خطر حقيقي أو حالة عاجلة.",
              "لا تضمن المنصة توفر استجابة طبية أو إسعاف أو قبول المريض في أي مؤسسة صحية.",
            ],
          },
          {
            title: "7. الاستخدام المقبول",
            paragraphs: [
              "يُمنع محاولة اختراق المنصة، أو تجاوز الصلاحيات، أو الوصول إلى بيانات لا تخص المستخدم أو مؤسسته، أو تعطيل الخدمة، أو استخدام المنصة لأي غرض غير قانوني.",
              "يجوز تعليق أو تقييد أو إنهاء الوصول عند وجود استخدام مخالف لهذه الشروط، أو عند الاشتباه في تهديد لأمن المنصة أو خصوصية البيانات.",
            ],
          },
          {
            title: "8. التوفر والتحديثات",
            paragraphs: [
              "نسعى إلى تحسين الخدمة والحفاظ على توفرها، لكن قد تتوقف بعض الوظائف مؤقتًا للصيانة أو التحديث أو لأسباب تقنية أو أمنية.",
              "يجوز تطوير المنصة أو تعديل وظائفها أو تحديث هذه الشروط عند الحاجة. يصبح استمرار الاستخدام بعد نشر التحديث موافقة على النسخة المحدّثة.",
            ],
          },
          {
            title: "9. المسؤولية",
            paragraphs: [
              "تُقدَّم المنصة كأداة تنظيمية تقنية. القرارات الطبية والتشخيصية والعلاجية تبقى مسؤولية الطبيب أو الطاقم الصحي والمؤسسة المعنية.",
              "لا تتحمل المنصة مسؤولية الأخطاء الناتجة عن بيانات غير صحيحة أو ناقصة تدخلها المؤسسة أو مستخدموها، أو عن سوء استخدام الحسابات والصلاحيات.",
            ],
          },
          {
            title: "10. التواصل",
            paragraphs: [
              "للاستفسار عن هذه الشروط أو طلب الانضمام أو الإبلاغ عن مشكلة، تواصل معنا عبر واتساب باستخدام الرابط المتوفر في هذه الصفحة.",
            ],
          },
        ],
        privacyIntro:
          "تشرح هذه السياسة أنواع البيانات التي قد تتم معالجتها عند استعمال منصة صحّتك تيك، وأسباب المعالجة، وطريقة التحكم في الوصول إليها.",
        privacySections: [
          {
            title: "1. من نحن",
            paragraphs: [
              "صحّتك تيك — DZ HEALTH TECH هي منصة رقمية موجهة للمؤسسات الصحية من أجل تنظيم بيانات المرضى، المستخدمين، الملفات الطبية، وسير العمل المرتبط بالخدمة.",
              "للاستفسارات المتعلقة بالخصوصية، يمكنك التواصل معنا عبر واتساب.",
            ],
          },
          {
            title: "2. البيانات التي قد نعالجها",
            paragraphs: [
              "بيانات الحساب: مثل الاسم، البريد الإلكتروني، رقم الهاتف، الدور داخل المؤسسة، وبيانات المصادقة اللازمة لتسجيل الدخول.",
              "بيانات المؤسسة الصحية: مثل اسم المؤسسة، الموقع أو العنوان، المستخدمين المرتبطين بها، والأدوار والصلاحيات.",
              "بيانات المريض: قد تشمل الاسم، رقم المريض، رقم الهاتف، البريد الإلكتروني، تاريخ الميلاد، الجنس، فصيلة الدم، الحساسية، الأمراض المزمنة، الأدوية، ملاحظات الطوارئ، والملفات الطبية التي تضيفها الجهة المخولة.",
              "بيانات الاستخدام والأمان: مثل عمليات تسجيل الدخول، نشاطات الإدارة، وسجل مسح QR بما في ذلك المؤسسة والموظف والوقت عند استخدام هذه الميزة.",
              "بيانات الطوارئ: عند استعمال ميزات الطوارئ، قد تشمل معلومات المريض الصحية الأساسية، حالة الطوارئ، وقت تسجيل الوصول، الملاحظات، وبيانات المؤسسة ذات الصلة.",
            ],
          },
          {
            title: "3. لماذا نعالج البيانات؟",
            paragraphs: [
              "لتشغيل المنصة وإدارة الحسابات والصلاحيات والمستخدمين داخل المؤسسات الصحية.",
              "لعرض معلومات المريض للموظفين المخولين، وتسهيل تنظيم الملفات الطبية وسجلات الرعاية.",
              "لتوفير ميزات QR والطوارئ، وتحسين الأمان، ومراجعة عمليات الوصول إلى المعلومات.",
              "للتواصل بشأن الدعم الفني، طلبات الانضمام، التحديثات، أو المسائل المتعلقة بالخدمة.",
            ],
          },
          {
            title: "4. الوصول إلى البيانات",
            paragraphs: [
              "لا يُفترض أن تكون بيانات المرضى متاحة للجميع. يعتمد الوصول على حساب المستخدم ودوره وصلته بالمؤسسة الصحية.",
              "يمكن للمستخدمين المخولين الاطلاع على المعلومات وفق الصلاحيات الممنوحة لهم. وقد تُقيّد بعض الإجراءات، مثل إضافة الملفات الطبية أو حذفها أو تنزيلها، لأدوار محددة.",
              "تتحمل المؤسسة مسؤولية تعيين المستخدمين وصلاحياتهم ومراجعتها وإزالة الوصول عند انتهاء الحاجة إليه.",
            ],
          },
          {
            title: "5. بيانات QR وسجل الوصول",
            paragraphs: [
              "عند مسح رمز QR صالح من قبل موظف مخول، قد يتم تسجيل عملية المسح لأغراض أمنية وتشغيلية، مثل تحديد المؤسسة والموظف والوقت.",
              "يساعد هذا السجل المؤسسة على متابعة الوصول إلى بيانات المرضى ودعم المراجعة الداخلية عند الحاجة.",
            ],
          },
          {
            title: "6. مشاركة البيانات",
            paragraphs: [
              "لا نبيع بيانات المرضى أو بيانات المؤسسات.",
              "تكون مشاركة البيانات داخل نطاق المؤسسة الصحية والمستخدمين المخولين بها حسب الصلاحيات. وقد يتم الإفصاح عن البيانات إذا تطلب القانون ذلك أو لحماية أمن المنصة والمستخدمين.",
              "يجب على المؤسسة الصحية عدم مشاركة بيانات المرضى خارج نطاقها إلا وفق الأساس القانوني أو الموافقات أو الالتزامات المهنية المطلوبة.",
            ],
          },
          {
            title: "7. الاحتفاظ بالبيانات",
            paragraphs: [
              "نحتفظ بالبيانات بالقدر اللازم لتشغيل المنصة، إدارة الحسابات، حفظ السجلات التشغيلية، وتلبية الالتزامات القانونية أو التعاقدية عند الاقتضاء.",
              "قد تختلف مدة الاحتفاظ بالبيانات الصحية أو السجلات الطبية بحسب سياسة المؤسسة الصحية والقوانين المطبقة عليها.",
            ],
          },
          {
            title: "8. حماية البيانات",
            paragraphs: [
              "نطبق تدابير تنظيمية وتقنية معقولة للمساعدة في حماية البيانات وتقليل الوصول غير المصرح به.",
              "مع ذلك، لا توجد خدمة رقمية تضمن أمانًا مطلقًا. يجب على المستخدمين حماية كلمات المرور وعدم مشاركة الحسابات، وعلى المؤسسات إدارة صلاحيات موظفيها بانتظام.",
            ],
          },
          {
            title: "9. حقوقك وطلباتك",
            paragraphs: [
              "يمكن للمستخدم أو المؤسسة طلب تصحيح معلومات الحساب أو تحديثها عبر القنوات المتاحة داخل المنصة أو بالتواصل معنا.",
              "بالنسبة لبيانات المرضى، يجب أن تُدار طلبات الوصول أو التصحيح أو الحذف بالتنسيق مع المؤسسة الصحية المسؤولة عن الملف، وبما يتوافق مع الالتزامات القانونية والمهنية ذات الصلة.",
            ],
          },
          {
            title: "10. التحديثات والتواصل",
            paragraphs: [
              "قد نحدّث هذه السياسة عند تطوير المنصة أو تغيير طريقة عملها. سيتم نشر التاريخ المحدّث في أعلى الصفحة.",
              "للاستفسارات المتعلقة بالخصوصية أو الإبلاغ عن مشكلة، تواصل معنا عبر واتساب.",
            ],
          },
        ],
      }
    : {
        back: "Retour à l'accueil",
        login: "Connexion",
        language: "العربية",
        title: "Conditions et confidentialité",
        subtitle:
          "Cette page présente les règles d'utilisation de DZ HEALTH TECH et la manière dont les données sont traitées sur la plateforme.",
        updated: "Dernière mise à jour : 24 août 2026",
        terms: "Conditions d'utilisation",
        privacy: "Politique de confidentialité",
        contact: "Nous contacter sur WhatsApp",
        noticeTitle: "Information importante",
        noticeText:
          "DZ HEALTH TECH est une plateforme numérique d'organisation. Elle ne fournit pas de diagnostic médical et ne remplace ni un médecin, ni le personnel soignant, ni les procédures officielles d'urgence.",
        termsIntro:
          "En utilisant la plateforme, en créant un compte ou en demandant l'adhésion d'un établissement, vous acceptez les présentes conditions. Si vous représentez un établissement, vous confirmez être autorisé à agir en son nom.",
        termsSections: [
          {
            title: "1. Objet du service",
            paragraphs: [
              "DZ HEALTH TECH fournit des outils numériques aux établissements de santé pour organiser les données patients, gérer les utilisateurs et les permissions, suivre les fichiers médicaux et utiliser un QR pour un accès autorisé aux informations nécessaires.",
              "La plateforme peut inclure des fonctions liées aux urgences. Ces fonctions sont des outils d'assistance et ne remplacent pas les numéros d'urgence, les protocoles médicaux ou l'évaluation d'un professionnel de santé.",
            ],
          },
          {
            title: "2. Comptes et autorisations",
            paragraphs: [
              "Les comptes et accès sont attribués selon le rôle dans l'établissement : administrateur, médecin ou personnel autorisé.",
              "L'administrateur de l'établissement est responsable de l'exactitude des comptes ajoutés, de la gestion des rôles et de la désactivation des accès qui ne sont plus nécessaires.",
              "Les identifiants doivent rester confidentiels. Toute utilisation non autorisée suspectée doit être signalée rapidement.",
            ],
          },
          {
            title: "3. Obligations de l'établissement",
            paragraphs: [
              "L'établissement confirme disposer d'une base légale et professionnelle appropriée pour saisir et traiter les données des patients dans la plateforme.",
              "L'établissement doit obtenir les autorisations nécessaires, respecter le secret professionnel et appliquer les règles de santé et de protection des données applicables en Algérie.",
              "La plateforme ne doit pas être utilisée pour introduire, partager ou rendre accessibles des données illicites, trompeuses ou destinées à des personnes non autorisées.",
            ],
          },
          {
            title: "4. Données patients et fichiers médicaux",
            paragraphs: [
              "L'établissement utilise la plateforme pour gérer les données qu'il saisit ou téléverse selon les autorisations de ses utilisateurs. Il reste responsable de l'exactitude, de la mise à jour et de la licéité de ces données.",
              "La gestion des fichiers médicaux dépend des autorisations. L'ajout, la suppression ou le téléchargement peuvent être réservés aux rôles autorisés, notamment au médecin.",
              "La plateforme ne doit pas être considérée comme l'unique solution d'archivage ou de sauvegarde exigée par les règles internes ou légales de l'établissement.",
            ],
          },
          {
            title: "5. Utilisation du QR",
            paragraphs: [
              "La plateforme peut proposer un QR associé au patient afin de permettre un accès rapide à certaines informations lorsque cela est nécessaire.",
              "Un QR ne doit être scanné et les données du patient ne doivent être consultées que par un membre du personnel autorisé, disposant d'un compte lié à un établissement actif.",
              "Les scans QR peuvent être enregistrés avec l'établissement, l'employé et l'heure afin de renforcer la sécurité et l'audit interne.",
            ],
          },
          {
            title: "6. Situations d'urgence",
            paragraphs: [
              "La plateforme propose des outils d'assistance numérique liés aux urgences, tels que l'affichage d'informations ciblées ou l'enregistrement de l'arrivée d'un patient dans un établissement.",
              "L'utilisateur et l'établissement doivent suivre les procédures médicales et légales applicables. En cas de danger réel ou d'urgence, contactez les services d'urgence officiels ou rendez-vous dans la structure de santé la plus proche.",
              "La plateforme ne garantit ni une réponse médicale, ni une ambulance, ni l'admission d'un patient dans un établissement.",
            ],
          },
          {
            title: "7. Usage acceptable",
            paragraphs: [
              "Il est interdit de tenter d'accéder à des données non autorisées, de contourner les permissions, d'attaquer la plateforme, de perturber le service ou d'utiliser la plateforme à des fins illégales.",
              "L'accès peut être suspendu, limité ou supprimé en cas de violation des conditions ou de risque pour la sécurité de la plateforme et des données.",
            ],
          },
          {
            title: "8. Disponibilité et mises à jour",
            paragraphs: [
              "Nous cherchons à maintenir et améliorer le service, mais certaines fonctions peuvent être temporairement indisponibles pour des raisons de maintenance, de mise à jour, de sécurité ou de technique.",
              "La plateforme, ses fonctions et les présentes conditions peuvent évoluer. La poursuite de l'utilisation après publication d'une mise à jour vaut acceptation de la version révisée.",
            ],
          },
          {
            title: "9. Responsabilité",
            paragraphs: [
              "La plateforme est un outil technique d'organisation. Les décisions médicales, diagnostiques et thérapeutiques restent sous la responsabilité du médecin, du personnel soignant et de l'établissement concerné.",
              "La plateforme ne peut être tenue responsable des erreurs dues à des données inexactes ou incomplètes fournies par l'établissement ou ses utilisateurs, ni d'un mauvais usage des comptes ou des autorisations.",
            ],
          },
          {
            title: "10. Contact",
            paragraphs: [
              "Pour toute question concernant ces conditions, une demande d'adhésion ou le signalement d'un problème, contactez-nous sur WhatsApp.",
            ],
          },
        ],
        privacyIntro:
          "Cette politique décrit les catégories de données susceptibles d'être traitées lors de l'utilisation de DZ HEALTH TECH, les raisons du traitement et la manière dont l'accès est contrôlé.",
        privacySections: [
          {
            title: "1. Qui sommes-nous ?",
            paragraphs: [
              "DZ HEALTH TECH est une plateforme numérique destinée aux établissements de santé pour organiser les données patients, les utilisateurs, les fichiers médicaux et certains flux de travail liés aux soins.",
              "Pour toute question sur la confidentialité, vous pouvez nous contacter via WhatsApp.",
            ],
          },
          {
            title: "2. Données pouvant être traitées",
            paragraphs: [
              "Données de compte : nom, e-mail, téléphone, rôle dans l'établissement et éléments nécessaires à l'authentification.",
              "Données de l'établissement : nom, localisation ou adresse, utilisateurs associés, rôles et permissions.",
              "Données patient : nom, identifiant patient, téléphone, e-mail, date de naissance, genre, groupe sanguin, allergies, maladies chroniques, médicaments, notes d'urgence et fichiers médicaux ajoutés par une personne autorisée.",
              "Données d'utilisation et de sécurité : connexions, activités d'administration et historique de scan QR comprenant notamment l'établissement, l'employé et l'heure lorsqu'une telle fonctionnalité est utilisée.",
              "Données d'urgence : informations médicales essentielles, statut de l'urgence, heure d'arrivée, notes et données de l'établissement concerné.",
            ],
          },
          {
            title: "3. Finalités du traitement",
            paragraphs: [
              "Faire fonctionner la plateforme et gérer les comptes, rôles, permissions et utilisateurs au sein des établissements.",
              "Afficher les informations patient aux personnes autorisées et faciliter l'organisation des fichiers médicaux et du suivi de soins.",
              "Fournir les fonctions QR et d'urgence, renforcer la sécurité et permettre l'audit des accès.",
              "Communiquer sur le support technique, les demandes d'adhésion, les mises à jour et les questions de service.",
            ],
          },
          {
            title: "4. Accès aux données",
            paragraphs: [
              "Les données patients ne sont pas destinées à être accessibles à tous. L'accès dépend du compte, du rôle et du lien de l'utilisateur avec l'établissement de santé.",
              "Les personnes autorisées consultent les informations selon les permissions attribuées. Certaines actions, comme l'ajout, la suppression ou le téléchargement de fichiers médicaux, peuvent être limitées à des rôles spécifiques.",
              "L'établissement est responsable de la désignation de ses utilisateurs, de la révision de leurs permissions et du retrait des accès lorsqu'ils ne sont plus justifiés.",
            ],
          },
          {
            title: "5. QR et historique d'accès",
            paragraphs: [
              "Lorsqu'un QR valide est scanné par un membre du personnel autorisé, l'opération peut être enregistrée à des fins de sécurité et de fonctionnement, notamment avec l'établissement, l'employé et l'heure.",
              "Cet historique aide l'établissement à suivre l'accès aux informations patient et à soutenir les contrôles internes.",
            ],
          },
          {
            title: "6. Partage des données",
            paragraphs: [
              "Nous ne vendons pas les données des patients ni celles des établissements.",
              "Les données sont partagées dans le périmètre de l'établissement de santé et de ses utilisateurs autorisés selon les permissions. Une communication peut aussi être nécessaire si la loi l'exige ou pour protéger la sécurité de la plateforme et des utilisateurs.",
              "L'établissement ne doit pas partager les données patients en dehors de son périmètre sans base légale, consentement ou obligation professionnelle applicable.",
            ],
          },
          {
            title: "7. Conservation",
            paragraphs: [
              "Les données sont conservées dans la mesure nécessaire au fonctionnement de la plateforme, à la gestion des comptes, aux journaux opérationnels et aux obligations légales ou contractuelles applicables.",
              "La durée de conservation des données médicales peut varier selon la politique de l'établissement et les règles qui lui sont applicables.",
            ],
          },
          {
            title: "8. Sécurité",
            paragraphs: [
              "Nous appliquons des mesures organisationnelles et techniques raisonnables pour aider à protéger les données et réduire les accès non autorisés.",
              "Aucun service numérique ne garantit une sécurité absolue. Les utilisateurs doivent protéger leurs mots de passe et les établissements doivent vérifier régulièrement les droits de leurs équipes.",
            ],
          },
          {
            title: "9. Vos demandes",
            paragraphs: [
              "Un utilisateur ou un établissement peut demander la correction ou la mise à jour des informations de compte par les canaux disponibles ou en nous contactant.",
              "Pour les données d'un patient, les demandes d'accès, de correction ou de suppression doivent être coordonnées avec l'établissement responsable du dossier et respecter les obligations légales et professionnelles applicables.",
            ],
          },
          {
            title: "10. Mises à jour et contact",
            paragraphs: [
              "Cette politique peut être mise à jour lors de l'évolution de la plateforme ou de ses pratiques. La date de mise à jour sera affichée en haut de cette page.",
              "Pour toute question sur la confidentialité ou pour signaler un problème, contactez-nous via WhatsApp.",
            ],
          },
        ],
      };

  const sections =
    activeTab === "terms" ? content.termsSections : content.privacySections;

  const intro = activeTab === "terms" ? content.termsIntro : content.privacyIntro;

  return (
    <main
      dir={isArabic ? "rtl" : "ltr"}
      className="min-h-screen bg-[#F7FBFF] text-[#152235]"
    >
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex h-[76px] max-w-6xl items-center justify-between px-5 lg:px-8">
          <Link href="/" className="flex items-center gap-3">
            <Image
              src="/logo.png"
              alt="صحّتك تيك — DZ HEALTH TECH"
              width={42}
              height={42}
              className="h-10 w-10 rounded-lg object-contain"
              priority
            />

            <div className="leading-tight">
              <p className="text-base font-extrabold text-[#07182A]">
                صحّتك تيك
              </p>
              <p className="mt-0.5 text-[10px] font-bold tracking-[0.16em] text-slate-500">
                DZ HEALTH TECH
              </p>
            </div>
          </Link>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => setLanguage(isArabic ? "fr" : "ar")}
              className="hidden rounded-lg px-3 py-2 text-sm font-bold text-slate-600 transition hover:bg-slate-100 sm:inline-flex"
            >
              {content.language}
            </button>

            <Link
              href="/admin/login"
              className="rounded-lg border border-slate-300 px-4 py-2.5 text-sm font-bold text-[#152235] transition hover:border-sky-300 hover:bg-sky-50"
            >
              {content.login}
            </Link>
          </div>
        </div>
      </header>

      <section className="border-b border-slate-200 bg-white">
        <div className="mx-auto max-w-5xl px-5 py-14 text-center sm:py-16">
          <Link
            href="/"
            className="inline-flex text-sm font-bold text-sky-600 transition hover:text-sky-700"
          >
            {content.back}
          </Link>

          <h1 className="mt-5 text-3xl font-black text-[#07182A] sm:text-4xl">
            {content.title}
          </h1>

          <p className="mx-auto mt-4 max-w-2xl leading-8 text-slate-600">
            {content.subtitle}
          </p>

          <p className="mt-5 text-xs font-semibold text-slate-400">
            {content.updated}
          </p>
        </div>
      </section>

      <section className="mx-auto max-w-5xl px-5 py-10 sm:py-14">
        <div className="rounded-2xl border border-amber-200 bg-amber-50 p-5">
          <p className="font-extrabold text-amber-900">{content.noticeTitle}</p>
          <p className="mt-2 text-sm leading-7 text-amber-800">
            {content.noticeText}
          </p>
        </div>

        <div className="mt-8 flex gap-2 rounded-xl border border-slate-200 bg-white p-2">
          <button
            type="button"
            onClick={() => setActiveTab("terms")}
            className={`flex-1 rounded-lg px-4 py-3 text-sm font-bold transition ${
              activeTab === "terms"
                ? "bg-[#07182A] text-white"
                : "text-slate-600 hover:bg-slate-50"
            }`}
          >
            {content.terms}
          </button>

          <button
            type="button"
            onClick={() => setActiveTab("privacy")}
            className={`flex-1 rounded-lg px-4 py-3 text-sm font-bold transition ${
              activeTab === "privacy"
                ? "bg-[#07182A] text-white"
                : "text-slate-600 hover:bg-slate-50"
            }`}
          >
            {content.privacy}
          </button>
        </div>

        <article className="mt-6 rounded-2xl border border-slate-200 bg-white p-6 sm:p-9">
          <p className="border-b border-slate-100 pb-7 leading-8 text-slate-600">
            {intro}
          </p>

          <div className="divide-y divide-slate-100">
            {sections.map((section) => (
              <section key={section.title} className="py-8">
                <h2 className="text-xl font-extrabold text-[#07182A]">
                  {section.title}
                </h2>

                <div className="mt-4 space-y-4">
                  {section.paragraphs.map((paragraph) => (
                    <p key={paragraph} className="leading-8 text-slate-600">
                      {paragraph}
                    </p>
                  ))}
                </div>
              </section>
            ))}
          </div>
        </article>

        <div className="mt-8 rounded-2xl bg-[#07182A] p-7 text-center text-white sm:p-9">
          <h2 className="text-xl font-extrabold">
            {isArabic ? "لديك سؤال أو طلب متعلق بالمنصة؟" : "Une question sur la plateforme ?"}
          </h2>

          <p className="mx-auto mt-3 max-w-xl text-sm leading-7 text-slate-300">
            {isArabic
              ? "يمكنك التواصل معنا مباشرة عبر واتساب بخصوص الانضمام، الخصوصية أو الدعم."
              : "Contactez-nous directement sur WhatsApp pour l'adhésion, la confidentialité ou le support."}
          </p>

          <a
            href={contactUrl}
            target="_blank"
            rel="noreferrer"
            className="mt-6 inline-flex rounded-lg bg-sky-500 px-6 py-3.5 text-sm font-bold text-white transition hover:bg-sky-400"
          >
            {content.contact}
          </a>
        </div>
      </section>

      <footer className="border-t border-slate-200 bg-white">
        <div className="mx-auto flex max-w-6xl flex-col gap-3 px-5 py-6 text-center text-xs text-slate-500 sm:flex-row sm:items-center sm:justify-between sm:text-start lg:px-8">
          <p>© 2026 DZ HEALTH TECH. {isArabic ? "جميع الحقوق محفوظة." : "Tous droits réservés."}</p>

          <a
            href="https://www.linkedin.com/in/mohammed-iyad-maamir-2340893a3/"
            target="_blank"
            rel="noreferrer"
            className="font-semibold text-sky-600 transition hover:text-sky-700"
          >
            Development & Maintenance: Mohammed Iyad Maamir
          </a>
        </div>
      </footer>
    </main>
  );
}