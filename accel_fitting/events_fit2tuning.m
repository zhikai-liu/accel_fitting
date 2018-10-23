function sum_vector=events_fit2tuning(event_index,fit_model)
    event_phase=event_index.*fit_model.b1+fit_model.c1;
    event_vector=1.*exp(1i.*event_phase');
    sum_vector=sum(event_vector);
end
