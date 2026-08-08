<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Patient\CompleteProfileRequest;
use App\Models\PatientProfile;
use Illuminate\Http\Request;

class MedicalProfileController extends Controller
{
    public function complete(CompleteProfileRequest $request)
    {
        $user = $request->user();

        $profile = $user->patientProfile ?? new PatientProfile([
            'user_id' => $user->id,
        ]);

        // الحقول الفعلية في PatientProfile:
        $profile->blood_group = $request->blood_group;
        $profile->date_of_birth = $request->date_of_birth;
        $profile->height_cm = $request->height;   // الأفضل توحيد الاسم مع العمود
        $profile->weight_kg = $request->weight;
        $profile->chronic_diseases = $request->chronic_diseases;
        $profile->allergies = $request->allergies;
        // ...

        // المهم:
        $profile->is_profile_complete = true;

        $profile->save();

        return response()->json([
            'message' => 'Profile completed successfully.',
            'profile' => [
                'blood_group' => $profile->blood_group,
                'date_of_birth' => $profile->date_of_birth,
                'height_cm' => $profile->height_cm,
                'weight_kg' => $profile->weight_kg,
                'chronic_diseases' => $profile->chronic_diseases,
                'allergies' => $profile->allergies,
                'is_profile_complete' => $profile->is_profile_complete,
            ],
        ]);
    }

}