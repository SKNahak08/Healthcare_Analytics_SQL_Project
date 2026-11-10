-- Monthly department report
drop procedure if exists department_report ;
delimiter //
create procedure department_report (in p_dept varchar(50), in p_year int)
begin
	select date_format(vb.bill_date, '%Y-%m') as month,
			count(*) as bills,
			round(sum(vb.total_amount), 0) as rrevenue
	from billing_detail vb
	join doctors d
		on d.doctor_id = vb.doctor_id
	join departments dep
		on dep.department_id = d.department_id
	where dep.department_name = p_dept
	and year(vb.bill_date) = p_year
	group by date_format(vb.bill_date, '%Y-%m')
	order by month ;
end //
delimiter ;