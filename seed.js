const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

// Insira as credenciais do seu projeto Supabase aqui
const SUPABASE_URL = 'https://SEU-PROJETO.supabase.co';
const SUPABASE_KEY = 'SUA-SERVICE-ROLE-OU-ANON-KEY';
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function importPlans() {
  const fileData = fs.readFileSync('./runmind_planos_completos.json', 'utf8');
  const jsonData = JSON.parse(fileData);

  console.log(`Iniciando importação de ${jsonData.total_plans} planos...`);

  for (const plan of jsonData.plans) {
    const { error: planError } = await supabase
      .from('workout_templates')
      .upsert({
        id: plan.id,
        level: plan.level,
        goal: plan.goal,
        age: plan.age,
        gender: plan.gender,
        plan_version: plan.plan_version,
        total_sessions: plan.weekly_summary.total_sessions,
        estimated_weekly_km: plan.weekly_summary.estimated_weekly_km,
        focus: plan.weekly_summary.focus
      });

    if (planError) {
      console.error(`Erro ao inserir plano ${plan.id}:`, planError);
      continue;
    }

    const itemsToInsert = plan.workouts.map((workout) => ({
      template_id: plan.id,
      day: workout.day,
      day_of_week: workout.day_of_week,
      type: workout.type,
      title: workout.title,
      description: workout.description,
      duration_min: workout.duration_min,
      distance_km: workout.distance_km,
      intensity: workout.intensity,
      rpe: workout.rpe,
      notes: workout.notes
    }));

    await supabase.from('workout_template_items').delete().eq('template_id', plan.id);
    const { error: itemsError } = await supabase
      .from('workout_template_items')
      .insert(itemsToInsert);

    if (itemsError) {
      console.error(`Erro nos itens do plano ${plan.id}:`, itemsError);
    } else {
      console.log(`Plano ${plan.id} (${plan.level} - ${plan.goal}) ok!`);
    }
  }

  console.log('Importação concluída com sucesso!');
}

importPlans();