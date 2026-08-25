"use client";

import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

type Language = "ar" | "fr";

const developer = {
  name: "Mohammed Iyad Maamir",
  linkedin: "https://www.linkedin.com/in/mohammed-iyad-maamir-2340893a3/",
  github: "https://github.com/maamirmohammediyad",
};

const whatsappNumber = "213542916461";

function getWhatsappUrl(language: Language) {
  const message =
    language === "ar"
      ? `السلام عليكم،

أرغب في طلب انضمام مؤسستي إلى منصة صحّتك تيك — DZ HEALTH TECH.

اسم المؤسسة:
نوع المؤسسة: مستشفى / عيادة / مركز طبي
الولاية والبلدية:
اسم المسؤول:
الصفة:
رقم الهاتف:
البريد الإلكتروني:
عدد الموظفين التقريبي:
ملاحظات أو احتياجات خاصة:

سأرسل وثيقة إثبات الصفة عند الطلب.`
      : `Bonjour,

Je souhaite inscrire mon établissement sur la plateforme DZ HEALTH TECH.

Nom de l'établissement :
Type : Hôpital / Clinique / Centre médical
Wilaya et commune :
Nom du responsable :
Fonction :
Téléphone :
E-mail :
Nombre approximatif d'employés :
Besoins ou remarques :

Je peux envoyer le justificatif demandé sur WhatsApp.`;

  return `https://wa.me/${whatsappNumber}?text=${encodeURIComponent(message)}`;
}

export default function HomePage() {
  const [language, setLanguage] = useState<Language>("ar");
  const isArabic = language === "ar";
  const whatsappUrl = getWhatsappUrl(language);

  const content = isArabic
    ? {
        brandDescription: "منصة جزائرية لتنظيم ملفات المرضى",
        nav: {
          home: "الرئيسية",
          features: "المزايا",
          workflow: "كيف تعمل",
          security: "الأمان",
          faq: "الأسئلة",
        },
        login: "تسجيل الدخول",
        join: "اطلب الانضمام",
        heroLabel: "منصة صحية رقمية للمؤسسات الجزائرية",
        heroTitleFirst: "إدارة صحية",
        heroTitleAccent: "أوضح وأسهل",
        heroTitleLast: " داخل مؤسستك.",
        heroText:
          "صحّتك تيك تساعد المستشفيات والعيادات والمراكز الطبية على تنظيم معلومات المرضى، إدارة الموظفين، والوصول السريع إلى البيانات المهمة عبر QR.",
        heroPrimary: "اطلب انضمام مؤسستك",
        heroSecondary: "اكتشف كيف تعمل",
        heroNoteOne: "للمستشفيات والعيادات والمراكز الطبية",
        heroNoteTwo: "واجهة عربية وفرنسية",
        heroNoteThree: "تواصل وتفعيل عبر واتساب",
        previewTitle: "ملف المريض في مكان واحد",
        previewText:
          "الوصول إلى أهم المعلومات الطبية حسب صلاحيات الموظف داخل المؤسسة.",
        previewPatient: "معلومات المريض",
        previewStatus: "سجل طبي منظّم",
        previewAllergies: "الحساسية",
        previewDiseases: "الأمراض المزمنة",
        previewMedication: "الأدوية",
        previewFiles: "الملفات الطبية",
        previewAccess: "وصول حسب الصلاحيات",
        featuresLabel: "كل ما تحتاجه مؤسستك",
        featuresTitle: "أدوات عملية لتنظيم الرعاية الصحية.",
        featuresText:
          "بدل الملفات المتفرقة والمعلومات التي يصعب الوصول إليها، تساعدك صحّتك تيك على تنظيم العمل في نقطة واحدة.",
        features: [
          {
            title: "ملف مريض موحّد",
            text: "بيانات المريض، الحساسية، الأمراض المزمنة، الأدوية والملفات الطبية في مكان واحد.",
          },
          {
            title: "وصول سريع عبر QR",
            text: "يمسح الموظف المخوّل رمز QR للوصول السريع إلى المعلومات الضرورية للمريض.",
          },
          {
            title: "إدارة الموظفين والأدوار",
            text: "أضف المديرين والموظفين ونظّم صلاحياتهم بما يتناسب مع طريقة عمل المؤسسة.",
          },
          {
            title: "دعم حالات الطوارئ",
            text: "الوصول السريع إلى معلومات المريض المهمة عند وجود حالة طوارئ نشطة.",
          },
          {
            title: "ملفات طبية منظّمة",
            text: "يعرض الفريق المخوّل الملفات، بينما تبقى إضافة الملفات وحذفها وتنزيلها للطبيب فقط.",
          },
          {
            title: "سجل QR للمراجعة",
            text: "تُسجل عمليات مسح QR مع المؤسسة والموظف والتوقيت لدعم المراجعة الداخلية.",
          },
        ],
        workflowLabel: "بدء بسيط",
        workflowTitle: "كيف تنضم مؤسستك إلى صحّتك تيك؟",
        workflowText:
          "لا تحتاج إلى تعبئة نموذج طويل أو إنشاء حساب مسبق. يبدأ كل شيء بمحادثة مباشرة عبر واتساب.",
        steps: [
          {
            title: "تواصل معنا",
            text: "اضغط على طلب الانضمام وأرسل معلومات مؤسستك عبر واتساب.",
          },
          {
            title: "نناقش احتياجاتك",
            text: "نتعرف على طبيعة مؤسستك ونوضح خطوات الانضمام والعرض المناسب.",
          },
          {
            title: "نفعّل مؤسستك",
            text: "بعد استكمال الإجراءات، نجهز المؤسسة وحساب المالك والمديرين.",
          },
        ],
        securityLabel: "الأمان والخصوصية",
        securityTitle: "كل مستخدم يرى ما يحتاجه فقط.",
        securityText:
          "تساعد الصلاحيات المنظمة على إبقاء المعلومات داخل نطاق العمل المناسب. لكل مؤسسة مساحة مستقلة، ويعتمد الوصول إلى البيانات على دور المستخدم داخلها.",
        securityList: [
          "مساحة مستقلة لكل مؤسسة صحية",
          "صلاحيات حسب الدور داخل المؤسسة",
          "الطبيب يدير الملفات الطبية",
          "سجل داخلي لعمليات مسح QR",
        ],
        terms: "اقرأ الشروط والبنود وسياسة الخصوصية",
        rolesTitle: "الصلاحيات داخل المؤسسة",
        roles: [
          ["مدير المؤسسة", "إدارة الفريق والأدوار"],
          ["الطبيب", "إدارة الملفات الطبية"],
          ["الموظف المخوّل", "عرض بيانات المريض حسب الصلاحية"],
        ],
        faqLabel: "الأسئلة الشائعة",
        faqTitle: "إجابات قبل أن تبدأ",
        faqs: [
          {
            question: "ما الذي سيجعلني أشترك في صحّتك تيك؟",
            answer:
              "لأنها تساعدك على جمع ملف المريض في مكان واحد، تنظيم العمل داخل المؤسسة، والوصول بسرعة إلى المعلومات الطبية المهمة عند الحاجة.",
          },
          {
            question: "هل المنصة مخصصة للمستشفيات فقط؟",
            answer:
              "لا. المنصة موجهة للمستشفيات والعيادات والمراكز الطبية في الجزائر.",
          },
          {
            question: "كيف يعمل QR الخاص بالمريض؟",
            answer:
              "يمسح الموظف المخوّل رمز QR للوصول إلى المعلومات المهمة للمريض، مع تسجيل عملية المسح للمراجعة داخل المؤسسة.",
          },
          {
            question: "من يستطيع إدارة الملفات الطبية؟",
            answer:
              "يمكن للموظفين المخولين عرض المعلومات، بينما يكون تنزيل الملفات الطبية وإضافتها وحذفها مخصصًا للطبيب.",
          },
          {
            question: "كيف يتم الانضمام؟",
            answer:
              "يتم الانضمام عبر واتساب. نناقش معلومات المؤسسة واحتياجاتها ثم نتابع إجراءات التفعيل.",
          },
          {
            question: "هل تظهر الأسعار في الموقع؟",
            answer:
              "يتم تقديم العرض بعد فهم احتياجات المؤسسة وطبيعة استخدامها للمنصة.",
          },
        ],
        ctaTitle: "ابدأ بتنظيم مؤسستك الصحية اليوم.",
        ctaText:
          "تواصل معنا عبر واتساب، وأرسل معلومات مؤسستك. سنوضح لك الخطوات المناسبة للانضمام.",
        ctaButton: "تواصل معنا عبر واتساب",
        footerProduct: "المنصة",
        footerCompany: "المعلومات",
        footerContact: "تواصل",
        footerLinks: {
          home: "الرئيسية",
          features: "المزايا",
          login: "تسجيل الدخول",
          terms: "الشروط والبنود",
          privacy: "سياسة الخصوصية",
          whatsapp: "واتساب",
        },
        developerTitle: "تطوير وصيانة المنصة",
        copyright: "جميع الحقوق محفوظة.",
        languageButton: "FR",
      }
    : {
        brandDescription: "Plateforme algérienne de gestion des dossiers patients",
        nav: {
          home: "Accueil",
          features: "Fonctionnalités",
          workflow: "Comment ça marche",
          security: "Sécurité",
          faq: "FAQ",
        },
        login: "Connexion",
        join: "Demander à rejoindre",
        heroLabel: "Plateforme de santé numérique pour les structures algériennes",
        heroTitleFirst: "Une gestion médicale",
        heroTitleAccent: "plus claire et simple",
        heroTitleLast: " pour votre établissement.",
        heroText:
          "DZ HEALTH TECH aide les hôpitaux, cliniques et centres médicaux à organiser les informations patients, gérer les équipes et accéder rapidement aux données importantes par QR.",
        heroPrimary: "Inscrire mon établissement",
        heroSecondary: "Découvrir la plateforme",
        heroNoteOne: "Pour hôpitaux, cliniques et centres médicaux",
        heroNoteTwo: "Interface arabe et française",
        heroNoteThree: "Contact et activation via WhatsApp",
        previewTitle: "Le dossier patient au même endroit",
        previewText:
          "Accès aux informations médicales essentielles selon les autorisations de chaque membre de l'équipe.",
        previewPatient: "Informations patient",
        previewStatus: "Dossier médical organisé",
        previewAllergies: "Allergies",
        previewDiseases: "Maladies chroniques",
        previewMedication: "Médicaments",
        previewFiles: "Fichiers médicaux",
        previewAccess: "Accès selon le rôle",
        featuresLabel: "Tout pour votre établissement",
        featuresTitle: "Des outils pratiques pour organiser les soins.",
        featuresText:
          "Au lieu de dossiers dispersés et d'informations difficiles à retrouver, DZ HEALTH TECH centralise l'essentiel.",
        features: [
          {
            title: "Dossier patient unifié",
            text: "Informations patient, allergies, maladies chroniques, traitements et fichiers médicaux au même endroit.",
          },
          {
            title: "Accès rapide par QR",
            text: "Le personnel autorisé scanne le QR pour consulter rapidement les informations nécessaires.",
          },
          {
            title: "Gestion des équipes et rôles",
            text: "Ajoutez des administrateurs et des employés, puis organisez les permissions selon votre fonctionnement.",
          },
          {
            title: "Prise en charge des urgences",
            text: "Accès rapide aux informations importantes lorsqu'une urgence active concerne le patient.",
          },
          {
            title: "Fichiers médicaux organisés",
            text: "Le personnel autorisé consulte les fichiers, tandis que le médecin les ajoute, les supprime et les télécharge.",
          },
          {
            title: "Historique QR",
            text: "Les scans QR sont enregistrés avec l'établissement, l'employé et l'heure pour le suivi interne.",
          },
        ],
        workflowLabel: "Démarrage simple",
        workflowTitle: "Comment rejoindre DZ HEALTH TECH ?",
        workflowText:
          "Pas de long formulaire ni de compte préalable. Tout commence par une discussion directe sur WhatsApp.",
        steps: [
          {
            title: "Contactez-nous",
            text: "Cliquez sur le bouton et envoyez les informations de votre établissement sur WhatsApp.",
          },
          {
            title: "Nous discutons de vos besoins",
            text: "Nous identifions votre structure, vos besoins et les étapes d'adhésion.",
          },
          {
            title: "Nous activons votre établissement",
            text: "Après les démarches nécessaires, nous préparons l'établissement et les comptes gestionnaires.",
          },
        ],
        securityLabel: "Sécurité et confidentialité",
        securityTitle: "Chaque utilisateur accède uniquement à ce dont il a besoin.",
        securityText:
          "Les autorisations gardent les informations dans le bon contexte. Chaque établissement dispose de son propre espace et l'accès dépend du rôle de l'utilisateur.",
        securityList: [
          "Espace indépendant par établissement",
          "Permissions selon le rôle",
          "Gestion des fichiers médicaux par le médecin",
          "Historique interne des scans QR",
        ],
        terms: "Lire les conditions et la politique de confidentialité",
        rolesTitle: "Rôles dans l'établissement",
        roles: [
          ["Administrateur", "Gestion de l'équipe et des rôles"],
          ["Médecin", "Gestion des fichiers médicaux"],
          ["Personnel autorisé", "Consultation selon les permissions"],
        ],
        faqLabel: "Questions fréquentes",
        faqTitle: "Avant de commencer",
        faqs: [
          {
            question: "Pourquoi rejoindre DZ HEALTH TECH ?",
            answer:
              "La plateforme centralise le dossier patient, organise le travail de la structure et accélère l'accès aux informations médicales essentielles.",
          },
          {
            question: "La plateforme est-elle réservée aux hôpitaux ?",
            answer:
              "Non. Elle s'adresse aussi aux cliniques et aux centres médicaux en Algérie.",
          },
          {
            question: "Comment fonctionne le QR patient ?",
            answer:
              "Le personnel autorisé scanne le QR pour accéder aux informations utiles du patient, et le scan est enregistré pour le suivi interne.",
          },
          {
            question: "Qui peut gérer les fichiers médicaux ?",
            answer:
              "Le personnel autorisé peut consulter les informations, tandis que le médecin ajoute, supprime et télécharge les fichiers médicaux.",
          },
          {
            question: "Comment rejoindre la plateforme ?",
            answer:
              "L'adhésion se fait via WhatsApp. Nous discutons de votre établissement, puis nous vous accompagnons pour l'activation.",
          },
          {
            question: "Les tarifs sont-ils affichés ?",
            answer:
              "Une proposition est communiquée après compréhension des besoins et de l'usage de l'établissement.",
          },
        ],
        ctaTitle: "Organisez votre établissement dès aujourd'hui.",
        ctaText:
          "Contactez-nous sur WhatsApp et envoyez les informations de votre établissement. Nous vous expliquons les prochaines étapes.",
        ctaButton: "Nous contacter sur WhatsApp",
        footerProduct: "Plateforme",
        footerCompany: "Informations",
        footerContact: "Contact",
        footerLinks: {
          home: "Accueil",
          features: "Fonctionnalités",
          login: "Connexion",
          terms: "Conditions",
          privacy: "Confidentialité",
          whatsapp: "WhatsApp",
        },
        developerTitle: "Développement et maintenance",
        copyright: "Tous droits réservés.",
        languageButton: "العربية",
      };

  return (
    <main
      dir={isArabic ? "rtl" : "ltr"}
      className="min-h-screen overflow-x-hidden bg-white text-[#152235]"
    >
      <header className="sticky top-0 z-40 border-b border-slate-200 bg-white/95 backdrop-blur">
        <div className="mx-auto flex h-[76px] max-w-7xl items-center justify-between px-5 lg:px-8">
          <Link href="/" className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center overflow-hidden rounded-xl">
              <Image
                src="/logo.png"
                alt="صحّتك تيك — DZ HEALTH TECH"
                width={40}
                height={40}
                className="h-10 w-10 object-contain"
                priority
              />
            </div>

            <div className="leading-tight">
              <p className="text-base font-extrabold text-[#07182A]">
                صحّتك تيك
              </p>
              <p className="mt-0.5 text-[10px] font-bold tracking-[0.16em] text-slate-500">
                DZ HEALTH TECH
              </p>
            </div>
          </Link>

          <nav className="hidden items-center gap-6 text-sm font-semibold text-slate-600 lg:flex">
            <a href="#home" className="transition hover:text-sky-600">
              {content.nav.home}
            </a>
            <a href="#features" className="transition hover:text-sky-600">
              {content.nav.features}
            </a>
            <a href="#workflow" className="transition hover:text-sky-600">
              {content.nav.workflow}
            </a>
            <a href="#security" className="transition hover:text-sky-600">
              {content.nav.security}
            </a>
            <a href="#faq" className="transition hover:text-sky-600">
              {content.nav.faq}
            </a>
          </nav>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => setLanguage(isArabic ? "fr" : "ar")}
              className="hidden rounded-lg px-3 py-2 text-sm font-bold text-slate-600 transition hover:bg-slate-100 sm:inline-flex"
            >
              {content.languageButton}
            </button>

            <Link
              href="/admin/login"
              className="hidden rounded-lg border border-slate-300 px-4 py-2.5 text-sm font-bold text-[#152235] transition hover:border-sky-300 hover:bg-sky-50 sm:inline-flex"
            >
              {content.login}
            </Link>

            <a
              href={whatsappUrl}
              target="_blank"
              rel="noreferrer"
              className="rounded-lg bg-sky-600 px-4 py-2.5 text-sm font-bold text-white transition hover:bg-sky-700"
            >
              {content.join}
            </a>
          </div>
        </div>
      </header>

      <section id="home" className="relative overflow-hidden bg-[#F7FBFF]">
        <div className="absolute inset-x-0 bottom-0 h-36 bg-gradient-to-t from-white to-transparent" />

        <div className="relative mx-auto grid max-w-7xl items-center gap-12 px-5 py-16 sm:py-20 lg:grid-cols-[1.04fr_0.96fr] lg:px-8 lg:py-24">
          <div className="max-w-2xl">
            <div className="inline-flex items-center gap-2 rounded-full border border-sky-200 bg-white px-4 py-2 text-xs font-bold text-sky-700 shadow-sm">
              <span className="h-2 w-2 rounded-full bg-sky-500" />
              {content.heroLabel}
            </div>

            <h1 className="mt-6 text-4xl font-black leading-[1.2] tracking-tight text-[#07182A] sm:text-5xl lg:text-6xl">
              {content.heroTitleFirst}{" "}
              <span className="text-sky-600">{content.heroTitleAccent}</span>{" "}
              {content.heroTitleLast}
            </h1>

            <p className="mt-6 max-w-xl text-base leading-8 text-slate-600 sm:text-lg">
              {content.heroText}
            </p>

            <div className="mt-8 flex flex-wrap gap-3">
              <a
                href={whatsappUrl}
                target="_blank"
                rel="noreferrer"
                className="rounded-lg bg-sky-600 px-6 py-3.5 text-sm font-bold text-white shadow-sm transition hover:bg-sky-700"
              >
                {content.heroPrimary}
              </a>

              <a
                href="#features"
                className="rounded-lg border border-slate-300 bg-white px-6 py-3.5 text-sm font-bold text-[#152235] transition hover:border-sky-300 hover:bg-sky-50"
              >
                {content.heroSecondary}
              </a>
            </div>

            <div className="mt-8 flex flex-wrap gap-x-6 gap-y-3 text-sm text-slate-500">
              <span className="flex items-center gap-2">
                <CheckIcon />
                {content.heroNoteOne}
              </span>
              <span className="flex items-center gap-2">
                <CheckIcon />
                {content.heroNoteTwo}
              </span>
              <span className="flex items-center gap-2">
                <CheckIcon />
                {content.heroNoteThree}
              </span>
            </div>
          </div>

          <ProductPreview content={content} />
        </div>
      </section>

      <section className="border-y border-slate-100 bg-white">
        <div className="mx-auto flex max-w-7xl flex-wrap items-center justify-center gap-x-12 gap-y-5 px-5 py-7 text-center text-sm font-semibold text-slate-500 lg:px-8">
          <span>المستشفيات</span>
          <span className="hidden h-4 w-px bg-slate-200 sm:block" />
          <span>العيادات</span>
          <span className="hidden h-4 w-px bg-slate-200 sm:block" />
          <span>المراكز الطبية</span>
          <span className="hidden h-4 w-px bg-slate-200 sm:block" />
          <span>مؤسسات الرعاية الصحية</span>
        </div>
      </section>

      <section id="features" className="bg-white py-20 lg:py-28">
        <div className="mx-auto max-w-7xl px-5 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <p className="text-sm font-bold text-sky-600">{content.featuresLabel}</p>
            <h2 className="mt-4 text-3xl font-black leading-tight text-[#07182A] sm:text-4xl">
              {content.featuresTitle}
            </h2>
            <p className="mt-5 leading-8 text-slate-600">{content.featuresText}</p>
          </div>

          <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {content.features.map((feature, index) => (
              <article
                key={feature.title}
                className="rounded-2xl border border-slate-200 bg-white p-6 transition hover:border-sky-200 hover:shadow-lg hover:shadow-slate-200/50"
              >
                <span className="flex h-10 w-10 items-center justify-center rounded-lg bg-sky-50 text-sm font-black text-sky-700">
                  0{index + 1}
                </span>
                <h3 className="mt-5 text-lg font-extrabold text-[#07182A]">
                  {feature.title}
                </h3>
                <p className="mt-3 text-sm leading-7 text-slate-600">{feature.text}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section id="workflow" className="bg-[#F7FBFF] py-20 lg:py-28">
        <div className="mx-auto max-w-7xl px-5 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <p className="text-sm font-bold text-sky-600">{content.workflowLabel}</p>
            <h2 className="mt-4 text-3xl font-black text-[#07182A] sm:text-4xl">
              {content.workflowTitle}
            </h2>
            <p className="mt-5 leading-8 text-slate-600">{content.workflowText}</p>
          </div>

          <div className="mt-12 grid gap-5 md:grid-cols-3">
            {content.steps.map((step, index) => (
              <article key={step.title} className="rounded-2xl border border-slate-200 bg-white p-7">
                <span className="text-4xl font-black text-sky-100">
                  0{index + 1}
                </span>
                <h3 className="mt-6 text-xl font-extrabold text-[#07182A]">
                  {step.title}
                </h3>
                <p className="mt-3 leading-7 text-slate-600">{step.text}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section id="security" className="bg-white py-20 lg:py-28">
        <div className="mx-auto grid max-w-7xl gap-12 px-5 lg:grid-cols-2 lg:items-center lg:px-8">
          <div>
            <p className="text-sm font-bold text-sky-600">{content.securityLabel}</p>
            <h2 className="mt-4 max-w-xl text-3xl font-black leading-tight text-[#07182A] sm:text-4xl">
              {content.securityTitle}
            </h2>
            <p className="mt-5 max-w-xl leading-8 text-slate-600">{content.securityText}</p>

            <div className="mt-7 space-y-3">
              {content.securityList.map((item) => (
                <div key={item} className="flex items-center gap-3 text-sm font-semibold text-slate-700">
                  <CheckIcon />
                  {item}
                </div>
              ))}
            </div>

            <Link
              href="/terms"
              className="mt-8 inline-flex rounded-lg border border-slate-300 px-5 py-3 text-sm font-bold text-[#152235] transition hover:border-sky-300 hover:bg-sky-50"
            >
              {content.terms}
            </Link>
          </div>

          <div className="rounded-2xl border border-slate-200 bg-[#F7FBFF] p-5 sm:p-7">
            <p className="text-sm font-bold text-[#07182A]">{content.rolesTitle}</p>

            <div className="mt-5 space-y-3">
              {content.roles.map(([role, permission], index) => (
                <div
                  key={role}
                  className="flex items-center justify-between gap-4 rounded-xl border border-slate-200 bg-white p-4"
                >
                  <div className="flex items-center gap-3">
                    <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-sky-50 text-sm font-bold text-sky-700">
                      {index + 1}
                    </span>
                    <span className="font-bold text-[#152235]">{role}</span>
                  </div>

                  <span className="text-left text-xs font-semibold leading-5 text-slate-500">
                    {permission}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      <section id="faq" className="bg-[#F7FBFF] py-20 lg:py-28">
        <div className="mx-auto max-w-4xl px-5">
          <div className="text-center">
            <p className="text-sm font-bold text-sky-600">{content.faqLabel}</p>
            <h2 className="mt-4 text-3xl font-black text-[#07182A] sm:text-4xl">
              {content.faqTitle}
            </h2>
          </div>

          <div className="mt-12 space-y-3">
            {content.faqs.map((faq) => (
              <details
                key={faq.question}
                className="group rounded-xl border border-slate-200 bg-white px-5 py-4 open:border-sky-200"
              >
                <summary className="flex cursor-pointer list-none items-center justify-between gap-4 text-sm font-extrabold text-[#152235]">
                  {faq.question}
                  <span className="text-xl font-normal text-sky-600 transition group-open:rotate-45">
                    +
                  </span>
                </summary>
                <p className="mt-4 max-w-3xl text-sm leading-7 text-slate-600">
                  {faq.answer}
                </p>
              </details>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-[#07182A] py-20 text-center text-white">
        <div className="mx-auto max-w-3xl px-5">
          <h2 className="text-3xl font-black leading-tight sm:text-4xl">
            {content.ctaTitle}
          </h2>
          <p className="mt-5 leading-8 text-slate-300">{content.ctaText}</p>

          <a
            href={whatsappUrl}
            target="_blank"
            rel="noreferrer"
            className="mt-8 inline-flex rounded-lg bg-sky-500 px-6 py-3.5 text-sm font-bold text-white transition hover:bg-sky-400"
          >
            {content.ctaButton}
          </a>
        </div>
      </section>

      <footer className="bg-[#04111F] text-slate-300">
        <div className="mx-auto grid max-w-7xl gap-10 px-5 py-14 sm:grid-cols-2 lg:grid-cols-4 lg:px-8">
          <div className="sm:col-span-2 lg:col-span-1">
            <div className="flex items-center gap-3">
              <Image
                src="/logo.png"
                alt="صحّتك تيك — DZ HEALTH TECH"
                width={42}
                height={42}
                className="h-10 w-10 rounded-lg object-contain"
              />
              <div>
                <p className="font-extrabold text-white">صحّتك تيك</p>
                <p className="text-[10px] font-bold tracking-[0.16em] text-slate-500">
                  DZ HEALTH TECH
                </p>
              </div>
            </div>

            <p className="mt-5 max-w-xs text-sm leading-7 text-slate-400">
              {content.brandDescription}
            </p>
          </div>

          <FooterLinks
            title={content.footerProduct}
            links={[
              [content.footerLinks.home, "#home"],
              [content.footerLinks.features, "#features"],
              [content.nav.workflow, "#workflow"],
              [content.login, "/admin/login"],
            ]}
          />

          <FooterLinks
            title={content.footerCompany}
            links={[
              [content.footerLinks.terms, "/terms"],
              [content.footerLinks.privacy, "/terms#privacy"],
              [content.nav.security, "#security"],
              [content.footerLinks.whatsapp, whatsappUrl],
            ]}
          />

          <div>
            <p className="text-sm font-bold text-white">{content.footerContact}</p>
            <a
              href={whatsappUrl}
              target="_blank"
              rel="noreferrer"
              className="mt-4 inline-flex text-sm font-semibold text-sky-300 transition hover:text-sky-200"
            >
              WhatsApp: +213 542 916 461
            </a>

            <div className="mt-8 border-t border-white/10 pt-6">
              <p className="text-xs font-bold text-slate-400">{content.developerTitle}</p>
              <p className="mt-2 text-sm font-semibold text-white">{developer.name}</p>

              <div className="mt-3 flex items-center gap-4 text-sm">
                <a
                  href={developer.linkedin}
                  target="_blank"
                  rel="noreferrer"
                  className="text-sky-300 transition hover:text-sky-200"
                >
                  LinkedIn
                </a>
                <a
                  href={developer.github}
                  target="_blank"
                  rel="noreferrer"
                  className="text-sky-300 transition hover:text-sky-200"
                >
                  GitHub
                </a>
              </div>
            </div>
          </div>
        </div>

        <div className="border-t border-white/10">
          <div className="mx-auto flex max-w-7xl flex-col gap-2 px-5 py-5 text-center text-xs text-slate-500 sm:flex-row sm:items-center sm:justify-between sm:text-start lg:px-8">
            <p>
              © {new Date().getFullYear()} DZ HEALTH TECH. {content.copyright}
            </p>
            <p>
              {content.developerTitle}: {developer.name}
            </p>
          </div>
        </div>
      </footer>
    </main>
  );
}

function ProductPreview({
  content,
}: {
  content: {
    previewTitle: string;
    previewText: string;
    previewPatient: string;
    previewStatus: string;
    previewAllergies: string;
    previewDiseases: string;
    previewMedication: string;
    previewFiles: string;
    previewAccess: string;
  };
}) {
  return (
    <div className="relative mx-auto w-full max-w-xl">
      <div className="rounded-[1.5rem] border border-slate-200 bg-white p-4 shadow-xl shadow-slate-200/70 sm:p-6">
        <div className="flex items-center justify-between border-b border-slate-100 pb-5">
          <div>
            <p className="text-base font-extrabold text-[#07182A]">
              {content.previewTitle}
            </p>
            <p className="mt-1 text-xs leading-5 text-slate-500">{content.previewText}</p>
          </div>

          <div className="grid h-14 w-14 grid-cols-4 gap-1 rounded-lg border border-slate-200 bg-white p-2">
            {Array.from({ length: 16 }).map((_, index) => (
              <span
                key={index}
                className={`rounded-[2px] ${
                  [0, 1, 4, 5, 10, 11, 14, 15].includes(index)
                    ? "bg-[#07182A]"
                    : "bg-slate-200"
                }`}
              />
            ))}
          </div>
        </div>

        <div className="mt-5 rounded-xl bg-[#F7FBFF] p-4">
          <div className="flex items-center justify-between gap-4">
            <div>
              <p className="text-xs font-semibold text-slate-500">{content.previewPatient}</p>
              <p className="mt-1 text-sm font-extrabold text-[#07182A]">
                {content.previewStatus}
              </p>
            </div>

            <span className="rounded-full bg-sky-100 px-3 py-1.5 text-xs font-bold text-sky-700">
              QR
            </span>
          </div>
        </div>

        <div className="mt-4 grid grid-cols-2 gap-3">
          <PreviewItem label={content.previewAllergies} />
          <PreviewItem label={content.previewDiseases} />
          <PreviewItem label={content.previewMedication} />
          <PreviewItem label={content.previewFiles} />
        </div>

        <div className="mt-4 flex items-center gap-2 rounded-xl border border-sky-100 bg-sky-50 px-4 py-3 text-xs font-bold text-sky-700">
          <CheckIcon />
          {content.previewAccess}
        </div>
      </div>
    </div>
  );
}

function PreviewItem({ label }: { label: string }) {
  return (
    <div className="rounded-lg border border-slate-100 p-3">
      <p className="text-xs font-semibold text-slate-500">{label}</p>
      <div className="mt-3 h-1.5 w-4/5 rounded-full bg-slate-100" />
    </div>
  );
}

function CheckIcon() {
  return (
    <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-sky-100 text-xs font-black text-sky-700">
      ✓
    </span>
  );
}

function FooterLinks({
  title,
  links,
}: {
  title: string;
  links: [string, string][];
}) {
  return (
    <div>
      <p className="text-sm font-bold text-white">{title}</p>
      <ul className="mt-4 space-y-3">
        {links.map(([label, href]) => {
          const isExternal = href.startsWith("http");

          return (
            <li key={`${label}-${href}`}>
              <a
                href={href}
                target={isExternal ? "_blank" : undefined}
                rel={isExternal ? "noreferrer" : undefined}
                className="text-sm text-slate-400 transition hover:text-sky-300"
              >
                {label}
              </a>
            </li>
          );
        })}
      </ul>
    </div>
  );
}